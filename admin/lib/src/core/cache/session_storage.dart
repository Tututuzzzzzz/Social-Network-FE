import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStorage {
  static const _accessTokenKey = 'admin_access_token';

  final FlutterSecureStorage _storage;

  const SessionStorage(this._storage);

  Future<String?> readAccessToken() async {
    final value = await _storage.read(key: _accessTokenKey);
    final token = value?.trim() ?? '';
    return token.isEmpty ? null : token;
  }

  Future<void> saveAccessToken(String token) {
    return _storage.write(key: _accessTokenKey, value: token);
  }

  Future<void> clear() {
    return _storage.delete(key: _accessTokenKey);
  }
}
