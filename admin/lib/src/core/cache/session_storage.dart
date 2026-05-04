import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStorage {
  static const _accessTokenKey = 'admin_access_token';
  static const _refreshTokenKey = 'admin_refresh_token';

  final FlutterSecureStorage _storage;

  const SessionStorage(this._storage);

  Future<String?> readAccessToken() async {
    final value = await _storage.read(key: _accessTokenKey);
    return _normalizeToken(value);
  }

  Future<String?> readRefreshToken() async {
    final value = await _storage.read(key: _refreshTokenKey);
    return _normalizeToken(value);
  }

  Future<({String accessToken, String? refreshToken})?> readTokens() async {
    final accessToken = await readAccessToken();
    if (accessToken == null) {
      return null;
    }

    return (accessToken: accessToken, refreshToken: await readRefreshToken());
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);

    final normalizedRefreshToken = refreshToken?.trim() ?? '';
    if (normalizedRefreshToken.isEmpty) {
      await _storage.delete(key: _refreshTokenKey);
      return;
    }

    await _storage.write(key: _refreshTokenKey, value: normalizedRefreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  String? _normalizeToken(String? value) {
    final token = value?.trim() ?? '';
    return token.isEmpty ? null : token;
  }
}
