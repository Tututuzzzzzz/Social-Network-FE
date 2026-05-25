import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart' as app;

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

  factory E2ESeedUser.fromJson(Map<String, dynamic> json) {
    return E2ESeedUser(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
    );
  }
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

  factory E2ESeedData.fromJson(Map<String, dynamic> json) {
    final users = (json['users'] as Map).cast<String, dynamic>();

    return E2ESeedData(
      runId: json['runId']?.toString() ?? '',
      scenario: json['scenario']?.toString() ?? '',
      primary: E2ESeedUser.fromJson(
        (users['primary'] as Map).cast<String, dynamic>(),
      ),
      admin: E2ESeedUser.fromJson(
        (users['admin'] as Map).cast<String, dynamic>(),
      ),
      friend: E2ESeedUser.fromJson(
        (users['friend'] as Map).cast<String, dynamic>(),
      ),
      requester: E2ESeedUser.fromJson(
        (users['requester'] as Map).cast<String, dynamic>(),
      ),
    );
  }
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
  static const startRoute = String.fromEnvironment('START_ROUTE');
  static const apiHost = String.fromEnvironment('API_HOST');
  static const apiPort = String.fromEnvironment('API_PORT');
  static const apiScheme = String.fromEnvironment('API_SCHEME');
  static const enableLogging = String.fromEnvironment('ENABLE_LOGGING');
  static const runId = String.fromEnvironment('E2E_RUN_ID');

  static String get resolvedApiHost {
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        (apiHost == 'localhost' || apiHost == '127.0.0.1')) {
      return '10.0.2.2';
    }

    return apiHost;
  }

  static Uri testApiUri(String path) {
    return Uri(
      scheme: apiScheme,
      host: resolvedApiHost,
      port: int.tryParse(apiPort),
      path: path,
    );
  }

  static Future<String> postJson(
    Uri url,
    Map<String, dynamic> body, {
    bool throwOnFailure = true,
  }) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      final request = await client.postUrl(url);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));

      final response = await request.close();
      final responseBody = await utf8.decoder.bind(response).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message =
            'Request $url failed with ${response.statusCode}: $responseBody';
        if (throwOnFailure) {
          throw TestFailure(message);
        }
        debugPrint(message);
      }

      return responseBody;
    } on TestFailure {
      rethrow;
    } catch (error) {
      if (throwOnFailure) {
        throw TestFailure('Request $url failed: $error');
      }
      debugPrint('Request $url failed: $error');
      return '';
    }
  }

  static Future<void> resetDatabase({bool throwOnFailure = true}) async {
    final url = testApiUri('/api/test/reset');
    debugPrint('[E2E] Resetting database via $url');
    await postJson(url, const {}, throwOnFailure: throwOnFailure);
  }

  static Future<E2ESeedData> seedDatabase({
    String scenario = 'social_network',
  }) async {
    final url = testApiUri('/api/test/seed');
    final requestedRunId = runId.trim().isNotEmpty
        ? runId.trim()
        : DateTime.now().millisecondsSinceEpoch.toString();

    debugPrint('[E2E] Seeding database via $url (runId=$requestedRunId)');
    final body = await postJson(url, {
      'scenario': scenario,
      'runId': requestedRunId,
      'reset': true,
    });

    final decoded = jsonDecode(body) as Map<String, dynamic>;
    if (decoded['ok'] != true || decoded['seed'] is! Map) {
      throw TestFailure('Invalid E2E seed response: $body');
    }

    return E2ESeedData.fromJson(
      (decoded['seed'] as Map).cast<String, dynamic>(),
    );
  }

  static Future<void> pumpApp(WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));
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
