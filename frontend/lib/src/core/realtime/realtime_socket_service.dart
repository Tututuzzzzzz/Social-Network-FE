import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../cache/secure_local_storage.dart';
import '../config/env_config.dart';
import '../utils/logger.dart';

/// Tên các socket events backend emit.
class SocketEvents {
  SocketEvents._();

  static const String connected = 'connected';
  static const String messageNew = 'message:new';
  static const String messageDeleted = 'message:deleted';
  static const String messageReaction = 'message:reaction';
  static const String messageSeen = 'message:seen';
  static const String conversationSeen = 'conversation:seen';
  static const String notificationNew = 'notification:new';
  static const String postEngagement = 'post:engagement';
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

  /// Số lần refresh liên tiếp thất bại. Reset về 0 khi connect thành công.
  int _refreshAttempts = 0;

  /// Giới hạn tối đa số lần refresh token liên tiếp.
  static const int _maxRefreshAttempts = 3;
  Completer<bool>? _refreshCompleter;

  // ── Streams cho từng event type ──────────────────────

  final _messageNewController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageDeletedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageReactionController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageSeenController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _conversationSeenController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _notificationNewController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _postEngagementController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _userOnlineController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _userOfflineController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  /// Stream khi có tin nhắn mới.
  Stream<Map<String, dynamic>> get messageNewStream =>
      _messageNewController.stream;

  /// Stream khi tin nhắn bị xóa.
  Stream<Map<String, dynamic>> get messageDeletedStream =>
      _messageDeletedController.stream;

  /// Stream khi có reaction mới trên tin nhắn.
  Stream<Map<String, dynamic>> get messageReactionStream =>
      _messageReactionController.stream;

  /// Stream khi tin nhắn được đọc.
  Stream<Map<String, dynamic>> get messageSeenStream =>
      _messageSeenController.stream;

  /// Stream khi conversation được seen (bulk).
  Stream<Map<String, dynamic>> get conversationSeenStream =>
      _conversationSeenController.stream;

  /// Stream khi có notification mới.
  Stream<Map<String, dynamic>> get notificationNewStream =>
      _notificationNewController.stream;

  /// Stream khi có like/comment realtime.
  Stream<Map<String, dynamic>> get postEngagementStream =>
      _postEngagementController.stream;

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
          .enableForceNew()
          .setAuth({'token': token})
          .build(),
    );

    _bindCoreListeners();
    _socket?.connect();
  }

  /// Ngắt kết nối socket. Gọi khi logout.
  void disconnect() {
    _cachedUserId = '';
    _refreshAttempts = 0;
    _refreshCompleter = null;
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
    _messageDeletedController.close();
    _messageReactionController.close();
    _messageSeenController.close();
    _conversationSeenController.close();
    _notificationNewController.close();
    _postEngagementController.close();
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
      // Reset refresh counter khi connect thành công
      _refreshAttempts = 0;
      _safeAdd(_connectionStateController, true);
    });

    _socket?.onDisconnect((_) {
      logger.w('Socket disconnected');
      _safeAdd(_connectionStateController, false);
    });

    _socket?.onReconnect((_) {
      logger.i('Socket reconnected: ${_socket?.id ?? 'unknown'}');
      _refreshAttempts = 0;
      _safeAdd(_connectionStateController, true);
    });

    _socket?.onConnectError((error) async {
      logger.e('Socket connect error: $error');

      // Nếu lỗi do token hết hạn → refresh rồi reconnect
      final errMsg = error?.toString() ?? '';
      final isTokenExpired =
          errMsg.contains('het han') ||
          errMsg.contains('khong hop le') ||
          errMsg.contains('Access token');

      if (isTokenExpired) {
        // Đã vượt quá số lần refresh cho phép → dừng hẳn, không retry nữa
        if (_refreshAttempts >= _maxRefreshAttempts) {
          logger.e(
            'Socket refresh: đã thử $_refreshAttempts lần, '
            'dừng reconnect để tránh vòng lặp vô hạn',
          );
          // Tắt socket auto-reconnect và disconnect sạch
          _socket?.disconnect();
          _socket?.dispose();
          _socket = null;
          _coreListenersBound = false;
          _safeAdd(_connectionStateController, false);
          return;
        }

        await _refreshAndReconnect();
      }
    });

    _socket?.onError((error) {
      logger.e('Socket error: $error');
    });

    // ── Event listeners ──

    _socket?.on(SocketEvents.messageNew, (payload) {
      _safeAddMap(_messageNewController, payload);
    });

    _socket?.on(SocketEvents.messageDeleted, (payload) {
      _safeAddMap(_messageDeletedController, payload);
    });

    _socket?.on(SocketEvents.messageReaction, (payload) {
      _safeAddMap(_messageReactionController, payload);
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

    _socket?.on(SocketEvents.postEngagement, (payload) {
      _safeAddMap(_postEngagementController, payload);
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

    // Socket.IO trên Flutter Web đôi khi wrap payload thành List([{...}]).
    // Unwrap phần tử đầu tiên nếu cần.
    final dynamic data = (payload is List && payload.isNotEmpty)
        ? payload.first
        : payload;

    if (data is Map) {
      final normalized = _normalizeSocketValue(data);
      if (normalized is Map<String, dynamic>) {
        controller.add(normalized);
      }
    }
  }

  dynamic _normalizeSocketValue(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, nestedValue) =>
            MapEntry(key.toString(), _normalizeSocketValue(nestedValue)),
      );
    }

    if (value is List) {
      return value.map(_normalizeSocketValue).toList();
    }

    return value;
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

  // ── Private: token refresh for socket ───────────────

  /// Gọi HTTP refresh-token rồi reconnect socket với access token mới.
  ///
  /// Dùng [Completer] để deduplicate: nếu nhiều onConnectError fire
  /// cùng lúc, chỉ 1 lần gọi API thật sự, các lần khác chờ kết quả.
  Future<void> _refreshAndReconnect() async {
    // Nếu đã có 1 refresh đang chạy → chờ nó xong, không gọi thêm
    if (_refreshCompleter != null) {
      logger.i('Socket refresh: đã có refresh đang chạy, chờ kết quả…');
      await _refreshCompleter!.future;
      return;
    }

    _refreshAttempts++;
    _refreshCompleter = Completer<bool>();

    try {
      // Tắt auto-reconnect của socket cũ trước khi refresh
      // để tránh socket.io tự retry với token hết hạn
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      _coreListenersBound = false;

      final refreshToken = await _secureLocalStorage.load(key: 'refresh_token');
      if (refreshToken.trim().isEmpty) {
        logger.e('Socket refresh: refresh token rỗng, không thể refresh');
        _refreshCompleter!.complete(false);
        return;
      }

      final dio = Dio(BaseOptions(baseUrl: EnvConfig.apiBaseUrl));
      final response = await dio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken.trim()},
      );

      final body = response.data;
      if (body is! Map) {
        logger.e('Socket refresh: response body không phải Map');
        _refreshCompleter!.complete(false);
        return;
      }

      final map = Map<String, dynamic>.from(body);
      final newAccessToken = map['accessToken']?.toString() ?? '';
      final newRefreshToken = map['refreshToken']?.toString() ?? '';

      if (newAccessToken.isEmpty) {
        logger.e('Socket refresh: empty access token in response');
        _refreshCompleter!.complete(false);
        return;
      }

      await _secureLocalStorage.save(
        key: 'access_token',
        value: newAccessToken,
      );
      if (newRefreshToken.isNotEmpty) {
        await _secureLocalStorage.save(
          key: 'refresh_token',
          value: newRefreshToken,
        );
      }

      _cachedUserId = '';

      logger.i('Socket refresh thành công, reconnecting…');
      _refreshCompleter!.complete(true);
      _refreshCompleter = null;

      // Reconnect với token mới
      await ensureConnected();
    } catch (e) {
      logger.e('Socket refresh failed: $e');
      _refreshCompleter?.complete(false);
      _refreshCompleter = null;
    }
  }
}
