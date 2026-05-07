import 'dart:convert';

import 'package:admin/src/features/auth/data/models/admin_session_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses access and refresh tokens from login response', () {
    final session = AdminSessionModel.fromLoginResponse({
      'accessToken': _jwtPayload({
        'userId': 'admin-1',
        'username': 'admin_user',
      }),
      'refreshToken': 'refresh-token-1',
      'isEmailVerified': true,
    });

    expect(session.accessToken, isNotEmpty);
    expect(session.refreshToken, 'refresh-token-1');
    expect(session.userId, 'admin-1');
    expect(session.username, 'admin_user');
    expect(session.isEmailVerified, isTrue);
  });

  test('restores refresh token with access token session', () {
    final session = AdminSessionModel.fromToken(
      _jwtPayload({'sub': 'admin-2'}),
      refreshToken: 'refresh-token-2',
    );

    expect(session.userId, 'admin-2');
    expect(session.refreshToken, 'refresh-token-2');
  });
}

String _jwtPayload(Map<String, dynamic> payload) {
  final encodedPayload = base64Url
      .encode(utf8.encode(jsonEncode(payload)))
      .replaceAll('=', '');
  return 'header.$encodedPayload.signature';
}
