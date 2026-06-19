import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart' as app;
import 'package:hive_flutter/hive_flutter.dart';

class E2ESeedUser {
  final String id;
  final String username;
  final String email;
  final String password;

  const E2ESeedUser({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
  });
}

class E2ESeedData {
  final String runId;
  final String scenario;
  final E2ESeedUser primary;
  final E2ESeedUser admin;
  final E2ESeedUser friend;
  final E2ESeedUser requester;

  const E2ESeedData({
    required this.runId,
    required this.scenario,
    required this.primary,
    required this.admin,
    required this.friend,
    required this.requester,
  });
}

class TestConfig {
  static const username = String.fromEnvironment('E2E_USERNAME');
  static const password = String.fromEnvironment('E2E_PASSWORD');
  static const baseEmail = String.fromEnvironment(
    'E2E_EMAIL',
    defaultValue: '',
  );
  static const registerPassword = String.fromEnvironment(
    'E2E_REGISTER_PASSWORD',
    defaultValue: '',
  );
  static const enableRegister = bool.fromEnvironment(
    'E2E_ENABLE_REGISTER',
    defaultValue: false,
  );
  static const enableMediaUpload = bool.fromEnvironment(
    'E2E_ENABLE_MEDIA_UPLOAD',
    defaultValue: false,
  );
  static const startRoute = String.fromEnvironment('START_ROUTE');
  static const apiHost = String.fromEnvironment('API_HOST');
  static const apiPort = String.fromEnvironment('API_PORT');
  static const apiScheme = String.fromEnvironment('API_SCHEME');
  static const enableLogging = String.fromEnvironment('ENABLE_LOGGING');

  static String get resolvedApiHost {
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        (apiHost == 'localhost' || apiHost == '127.0.0.1')) {
      return '10.0.2.2';
    }

    return apiHost;
  }

  // ── Seed data cố định — khớp với e2e-seed.ts (prefix = 'e2e') ─────────────

  static const _seedPassword = 'Password123!';

  /// Seed data cố định — backend auto-seed khi khởi động
  /// Username/password khớp với e2e-seed.ts (prefix = 'e2e')
  static E2ESeedData getSeedData() {
    return const E2ESeedData(
      runId: 'auto',
      scenario: 'social_network',
      primary: E2ESeedUser(
        id: '',
        username: 'e2e_user',
        email: 'e2e.user@example.test',
        password: _seedPassword,
      ),
      admin: E2ESeedUser(
        id: '',
        username: 'e2e_admin',
        email: 'e2e.admin@example.test',
        password: _seedPassword,
      ),
      friend: E2ESeedUser(
        id: '',
        username: 'e2e_friend',
        email: 'e2e.friend@example.test',
        password: _seedPassword,
      ),
      requester: E2ESeedUser(
        id: '',
        username: 'e2e_requester',
        email: 'e2e.requester@example.test',
        password: _seedPassword,
      ),
    );
  }

  /// Setup chung cho mọi test file — clear local storage + khởi tạo app
  static Future<E2ESeedData> setupTest(WidgetTester tester) async {
    validateCoreEnvironment();
    try {
      log('[E2E] Clearing Hive local storage...', name: 'E2E');
      await Hive.initFlutter();
      await Hive.deleteFromDisk();
      log('[E2E] Hive local storage cleared.', name: 'E2E');
    } catch (error) {
      log('[E2E] Failed to clear Hive local storage: $error', name: 'E2E');
    }
    await pumpApp(tester);
    return getSeedData();
  }

  static Future<void> pumpApp(WidgetTester tester) async {
    await app.main();
    // Chờ màn hình đầu tiên render xong thay vì delay cứng 5s
    // Có thể là WelcomeScreen hoặc LoginScreen tùy trạng thái
    await tester.pumpAndSettle();
  }

  static void requireEnv(String value, String name) {
    expect(
      value.trim(),
      isNotEmpty,
      reason: 'Missing $name (set in .env.e2e or --dart-define=$name=...)',
    );
  }

  static void validateCoreEnvironment() {
    requireEnv(startRoute, 'START_ROUTE');
    requireEnv(apiHost, 'API_HOST');
    requireEnv(apiPort, 'API_PORT');
    requireEnv(apiScheme, 'API_SCHEME');
    requireEnv(enableLogging, 'ENABLE_LOGGING');
  }
}
