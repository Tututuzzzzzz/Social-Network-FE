import 'dart:async';
import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../cache/secure_local_storage.dart';
import '../config/env_config.dart';
import '../utils/logger.dart';

/// Tên các socket events backend emit.
class SocketEvents {
  SocketEvents._();

  static const String connected = 'connected';
  static const String messageNew = 'message:new';
  static const String messageSeen = 'message:seen';
  static const String conversationSeen = 'conversation:seen';
  static const String notificationNew = 'notification:new';
  static const String userOnline = 'user:online';
  static const String userOffline = 'user:offline';
}

/// Service quản lý kết nối Socket.IO realtime.
///
/// - Connect tự động ngay sau login (gọi tại AppShellPage).
/// - Auto-reconnect khi mất mạng.
/// - Multi-stream cho từng loại event.
/// - Disconnect khi logout.
class RealtimeSocketService {
  final SecureLocalStorage _secureLocalStorage;

  RealtimeSocketService(this._secureLocalStorage);

  io.Socket? _socket;
  bool _coreListenersBound = false;
  String _cachedUserId = '';

  // ── Streams cho từng event type ──────────────────────

  final _messageNewController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageSeenController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _conversationSeenController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _notificationNewController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _userOnlineController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _userOfflineController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  /// Stream khi có tin nhắn mới.
  Stream<Map<String, dynamic>> get messageNewStream =>
      _messageNewController.stream;

  /// Stream khi tin nhắn được đọc.
  Stream<Map<String, dynamic>> get messageSeenStream =>
      _messageSeenController.stream;

  /// Stream khi conversation được seen (bulk).
  Stream<Map<String, dynamic>> get conversationSeenStream =>
      _conversationSeenController.stream;

  /// Stream khi có notification mới.
  Stream<Map<String, dynamic>> get notificationNewStream =>
      _notificationNewController.stream;

  /// Stream khi bạn bè online.
  Stream<Map<String, dynamic>> get userOnlineStream =>
      _userOnlineController.stream;

  /// Stream khi bạn bè offline.
  Stream<Map<String, dynamic>> get userOfflineStream =>
      _userOfflineController.stream;

  /// Stream trạng thái kết nối (true = connected, false = disconnected).
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  /// Socket hiện tại có đang connected không.
  bool get isConnected => _socket?.connected ?? false;

  // ── Backward compatibility ───────────────────────────

  /// Alias cho [messageNewStream] — tương thích code cũ.
  Stream<Map<String, dynamic>> get newMessageStream => messageNewStream;

  // ── Connection lifecycle ─────────────────────────────

  /// Kết nối socket. Gọi sau khi login thành công.
  /// Nếu đã connected thì skip.
  Future<void> ensureConnected() async {
    if (_socket?.connected == true) {
      return;
    }

    final token = await _secureLocalStorage.load(key: 'access_token');
    if (token.trim().isEmpty) {
      logger.w('Socket connect skipped: access token is empty');
      return;
    }

    // Cache userId để khỏi decode JWT mỗi lần
    if (_cachedUserId.isEmpty) {
      _cachedUserId = _extractUserIdFromJwt(token);
    }

    final socketBaseUrl = EnvConfig.socketBaseUrl;

    _socket?.dispose();
    _coreListenersBound = false;

    _socket = io.io(
      socketBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          .setAuth({'token': token})
          .build(),
    );

    _bindCoreListeners();
    _socket?.connect();
  }

  /// Ngắt kết nối socket. Gọi khi logout.
  void disconnect() {
    _cachedUserId = '';
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _coreListenersBound = false;

    if (!_connectionStateController.isClosed) {
      _connectionStateController.add(false);
    }

    logger.i('Socket disconnected (manual)');
  }

  /// Giải phóng resources. Gọi khi app bị kill.
  void dispose() {
    disconnect();
    _messageNewController.close();
    _messageSeenController.close();
    _conversationSeenController.close();
    _notificationNewController.close();
    _userOnlineController.close();
    _userOfflineController.close();
    _connectionStateController.close();
  }

  // ── Public helpers ───────────────────────────────────

  /// Lấy userId từ JWT (cached sau lần đầu).
  Future<String> getCurrentUserId() async {
    if (_cachedUserId.isNotEmpty) {
      return _cachedUserId;
    }

    final token = await _secureLocalStorage.load(key: 'access_token');
    if (token.trim().isEmpty) {
      return '';
    }

    _cachedUserId = _extractUserIdFromJwt(token);
    return _cachedUserId;
  }

  /// Join vào room conversation để nhận message:new.
  void joinConversation(String conversationId) {
    if (conversationId.trim().isEmpty) {
      return;
    }

    _socket?.emit('conversation:join', conversationId);
  }

  // ── Private: bind listeners ──────────────────────────

  void _bindCoreListeners() {
    if (_socket == null || _coreListenersBound) {
      return;
    }

    _coreListenersBound = true;

    // Connection lifecycle
    _socket?.onConnect((_) {
      logger.i('Socket connected: ${_socket?.id ?? 'unknown'}');
      _safeAdd(_connectionStateController, true);
    });

    _socket?.onDisconnect((_) {
      logger.w('Socket disconnected');
      _safeAdd(_connectionStateController, false);
    });

    _socket?.onReconnect((_) {
      logger.i('Socket reconnected: ${_socket?.id ?? 'unknown'}');
      _safeAdd(_connectionStateController, true);
    });

    _socket?.onConnectError((error) {
      logger.e('Socket connect error: $error');
    });

    _socket?.onError((error) {
      logger.e('Socket error: $error');
    });

    // ── Event listeners ──

    _socket?.on(SocketEvents.messageNew, (payload) {
      _safeAddMap(_messageNewController, payload);
    });

    _socket?.on(SocketEvents.messageSeen, (payload) {
      _safeAddMap(_messageSeenController, payload);
    });

    _socket?.on(SocketEvents.conversationSeen, (payload) {
      _safeAddMap(_conversationSeenController, payload);
    });

    _socket?.on(SocketEvents.notificationNew, (payload) {
      _safeAddMap(_notificationNewController, payload);
    });

    _socket?.on(SocketEvents.userOnline, (payload) {
      _safeAddMap(_userOnlineController, payload);
    });

    _socket?.on(SocketEvents.userOffline, (payload) {
      _safeAddMap(_userOfflineController, payload);
    });
  }

  // ── Private: safe stream helpers ─────────────────────

  void _safeAdd<T>(StreamController<T> controller, T value) {
    if (!controller.isClosed) {
      controller.add(value);
    }
  }

  void _safeAddMap(
    StreamController<Map<String, dynamic>> controller,
    dynamic payload,
  ) {
    if (controller.isClosed) return;
    if (payload is Map) {
      controller.add(Map<String, dynamic>.from(payload));
    }
  }

  // ── Private: JWT decode ──────────────────────────────

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
