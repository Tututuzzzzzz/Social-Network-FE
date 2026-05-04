import 'dart:convert';

import '../../domain/entities/admin_session.dart';

class AdminSessionModel extends AdminSession {
  const AdminSessionModel({
    required super.accessToken,
    super.refreshToken,
    required super.userId,
    required super.username,
    required super.isEmailVerified,
  });

  factory AdminSessionModel.fromLoginResponse(Map<String, dynamic> json) {
    final token = (json['accessToken'] ?? '').toString().trim();
    final refreshToken = (json['refreshToken'] ?? json['refresh_token'] ?? '')
        .toString()
        .trim();
    final payload = _decodeJwtPayload(token);

    return AdminSessionModel(
      accessToken: token,
      refreshToken: refreshToken.isEmpty ? null : refreshToken,
      userId: (payload['userId'] ?? payload['sub'] ?? '').toString(),
      username: (payload['username'] ?? json['username'] ?? 'admin').toString(),
      isEmailVerified: json['isEmailVerified'] == true,
    );
  }

  factory AdminSessionModel.fromToken(String token, {String? refreshToken}) {
    final payload = _decodeJwtPayload(token);

    return AdminSessionModel(
      accessToken: token,
      refreshToken: refreshToken,
      userId: (payload['userId'] ?? payload['sub'] ?? '').toString(),
      username: (payload['username'] ?? 'admin').toString(),
      isEmailVerified: true,
    );
  }

  static Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return const {};
      }

      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      if (payload is Map) {
        return Map<String, dynamic>.from(payload);
      }
    } catch (_) {
      return const {};
    }

    return const {};
  }
}
