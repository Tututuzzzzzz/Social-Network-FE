import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart' as app;

class TestConfig {
  static const username = String.fromEnvironment('E2E_USERNAME');
  static const password = String.fromEnvironment('E2E_PASSWORD');
  static const baseEmail = String.fromEnvironment('E2E_EMAIL', defaultValue: '');
  static const registerPassword = String.fromEnvironment(
    'E2E_REGISTER_PASSWORD',
    defaultValue: '',
  );
  static const enableRegister = bool.fromEnvironment(
    'E2E_ENABLE_REGISTER',
    defaultValue: false,
  );
  static const startRoute = String.fromEnvironment('START_ROUTE');
  static const apiHost = String.fromEnvironment('API_HOST');
  static const apiPort = String.fromEnvironment('API_PORT');
  static const apiScheme = String.fromEnvironment('API_SCHEME');
  static const enableLogging = String.fromEnvironment('ENABLE_LOGGING');

  /// Reset cơ sở dữ liệu trên E2E Backend Server
  static Future<void> resetDatabase() async {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;

    final resolvedHost = (Platform.isAndroid && (apiHost == 'localhost' || apiHost == '127.0.0.1'))
        ? '10.0.2.2'
        : apiHost;

    final url = Uri(
      scheme: apiScheme,
      host: resolvedHost,
      port: int.tryParse(apiPort),
      path: '/api/test/reset',
    );
    
    print('🧹 [E2E] Đang gửi yêu cầu reset database tới: $url');
    final request = await client.postUrl(url);
    final response = await request.close();
    
    if (response.statusCode != 200) {
      throw TestFailure(
        '❌ [E2E] Reset database thất bại. Status: ${response.statusCode}. '
        'Kiểm tra E2E backend tại [$apiScheme://$apiHost:$apiPort] đã khởi động.',
      );
    }
    print('✅ [E2E] Reset database thành công!');
  }

  /// Khởi động ứng dụng trong môi trường test
  static Future<void> pumpApp(WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  /// Đảm bảo biến môi trường bắt buộc được điền đầy đủ
  static void requireEnv(String value, String name) {
    expect(
      value.trim(),
      isNotEmpty,
      reason: 'Missing $name (set in .env.e2e or --dart-define=$name=...)',
    );
  }

  /// Xác thực toàn bộ các cấu hình bắt buộc trước khi thực thi
  static void validateCoreEnvironment() {
    requireEnv(startRoute, 'START_ROUTE');
    requireEnv(apiHost, 'API_HOST');
    requireEnv(apiPort, 'API_PORT');
    requireEnv(apiScheme, 'API_SCHEME');
    requireEnv(enableLogging, 'ENABLE_LOGGING');
  }
}
