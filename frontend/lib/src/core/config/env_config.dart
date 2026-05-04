import 'package:flutter/foundation.dart';

/// Cấu hình môi trường — đọc từ file `.env` qua `--dart-define-from-file`.
///
/// Cách chạy:
/// ```bash
/// # Development
/// flutter run --dart-define-from-file=.env.development
///
/// # Production
/// flutter run --dart-define-from-file=.env.production
///
/// # Build release
/// flutter build apk --dart-define-from-file=.env.production
/// ```
///
/// Nếu không truyền `--dart-define-from-file`, sẽ dùng giá trị mặc định (dev).
class EnvConfig {
  EnvConfig._();

  // ── Đọc từ .env (compile-time constants) ──────────────

  static const String _apiHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'localhost',
  );

  static const String _apiPort = String.fromEnvironment(
    'API_PORT',
    defaultValue: '3001',
  );

  static const String _apiScheme = String.fromEnvironment(
    'API_SCHEME',
    defaultValue: 'http',
  );

  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  // ── Computed URLs ─────────────────────────────────────

  /// Base URL cho REST API.
  /// Android emulator dùng 10.0.2.2 thay cho localhost.
  static String get apiBaseUrl {
    final host = _resolveHost(_apiHost);
    final portSuffix = _needsPort ? ':$_apiPort' : '';
    return '$_apiScheme://$host$portSuffix/api';
  }

  /// Base URL cho Socket.IO (không có /api).
  static String get socketBaseUrl {
    final host = _resolveHost(_apiHost);
    final portSuffix = _needsPort ? ':$_apiPort' : '';
    return '$_apiScheme://$host$portSuffix';
  }

  /// Đang chạy dev hay prod.
  static bool get isDevelopment =>
      _apiHost == 'localhost' || _apiHost == '127.0.0.1';

  static bool get isProduction => !isDevelopment;

  // ── Private helpers ───────────────────────────────────

  /// Android emulator không truy cập được localhost.
  static String _resolveHost(String host) {
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        (host == 'localhost' || host == '127.0.0.1')) {
      return '10.0.2.2';
    }
    return host;
  }

  /// Bỏ port nếu scheme dùng port mặc định (http:80, https:443).
  static bool get _needsPort {
    if (_apiScheme == 'https' && _apiPort == '443') return false;
    if (_apiScheme == 'http' && _apiPort == '80') return false;
    return true;
  }
}
