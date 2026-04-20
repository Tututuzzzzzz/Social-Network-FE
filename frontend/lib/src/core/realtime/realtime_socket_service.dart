import 'dart:async';
import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../api/api_constants.dart';
import '../cache/secure_local_storage.dart';
import '../utils/logger.dart';

class RealtimeSocketService {
  final SecureLocalStorage _secureLocalStorage;

  RealtimeSocketService(this._secureLocalStorage);

  io.Socket? _socket;
  bool _coreListenersBound = false;

  final StreamController<Map<String, dynamic>> _newMessageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get newMessageStream =>
      _newMessageController.stream;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> ensureConnected() async {
    if (_socket?.connected == true) {
      return;
    }

    final token = await _secureLocalStorage.load(key: 'access_token');
    if (token.trim().isEmpty) {
      logger.w('Socket connect skipped: access token is empty');
      return;
    }

    final socketBaseUrl = _toSocketBaseUrl(ApiConstants.baseUrl);

    _socket?.dispose();
    _coreListenersBound = false;
    _socket = io.io(
      socketBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _bindCoreListeners();
    _socket?.connect();
  }

  Future<String> getCurrentUserId() async {
    final token = await _secureLocalStorage.load(key: 'access_token');
    if (token.trim().isEmpty) {
      return '';
    }

    return _extractUserIdFromJwt(token);
  }

  void joinConversation(String conversationId) {
    if (conversationId.trim().isEmpty) {
      return;
    }

    _socket?.emit('conversation:join', conversationId);
  }

  void dispose() {
    _newMessageController.close();
    _socket?.dispose();
    _socket = null;
  }

  void _bindCoreListeners() {
    if (_socket == null || _coreListenersBound) {
      return;
    }

    _coreListenersBound = true;

    _socket?.onConnect((_) {
      logger.i('Socket connected: ${_socket?.id ?? 'unknown'}');
    });

    _socket?.onConnectError((error) {
      logger.e('Socket connect error: $error');
    });

    _socket?.onError((error) {
      logger.e('Socket error: $error');
    });

    _socket?.on('message:new', (payload) {
      if (payload is Map) {
        _newMessageController.add(Map<String, dynamic>.from(payload));
      }
    });
  }

  String _toSocketBaseUrl(String apiBaseUrl) {
    final uri = Uri.parse(apiBaseUrl);
    final path = uri.path;

    final cleanedPath = path.endsWith('/api')
        ? path.substring(0, path.length - 4)
        : path;

    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: cleanedPath,
    ).toString();
  }

  String _extractUserIdFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return '';
      }

      final normalizedPayload = base64Url.normalize(parts[1]);
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));
      final payload = jsonDecode(decodedPayload);

      if (payload is! Map) {
        return '';
      }

      final map = Map<String, dynamic>.from(payload);
      return map['userId']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }
}
