import 'dart:convert';

import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/cache/secure_local_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/login_model.dart';
import '../models/register_model.dart';
import '../models/user_model.dart';

sealed class AuthRemoteDataSource {
  Future<UserModel> login(LoginModel model);
  Future<void> logout();
  Future<String> refreshSession();
  Future<void> register(RegisterModel model);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiHelper _apiHelper;
  final SecureLocalStorage _secureLocalStorage;
  const AuthRemoteDataSourceImpl(this._apiHelper, this._secureLocalStorage);

  @override
  Future<UserModel> login(LoginModel model) async {
    try {
      final result = await _apiHelper.execute(
        method: Method.post,
        url: ApiConstants.login,
        data: model.toJson(),
      );

      final accessToken = result['accessToken']?.toString() ?? '';
      final refreshToken = result['refreshToken']?.toString() ?? '';
      if (accessToken.isEmpty) {
        throw ServerException();
      }
      await _secureLocalStorage.save(key: 'access_token', value: accessToken);
      if (refreshToken.isNotEmpty) {
        await _secureLocalStorage.save(
          key: 'refresh_token',
          value: refreshToken,
        );
      }

      final payload = result['user'] ?? result;
      final json = payload is Map<String, dynamic>
          ? Map<String, dynamic>.from(payload)
          : payload is Map
          ? Map<String, dynamic>.from(payload)
          : <String, dynamic>{};

      final tokenUserId = _extractUserIdFromAccessToken(accessToken);
      final userId = (json['_id'] ?? json['id'] ?? tokenUserId ?? '')
          .toString();

      return UserModel(
        userId: userId.isNotEmpty ? userId : null,
        userName: (json['username'] ?? result['username'])?.toString(),
        email: json['email']?.toString(),
      );
    } on UnauthorisedException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      throw ServerException();
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await _secureLocalStorage.load(key: 'refresh_token');
      try {
        await _apiHelper.execute(
          method: Method.post,
          url: ApiConstants.logout,
          data: {
            if (refreshToken.trim().isNotEmpty)
              'refreshToken': refreshToken.trim(),
          },
        );
      } catch (_) {
        // If the server session is already expired, local cleanup still proceeds.
      }
      return;
    } catch (e) {
      logger.e(e);
      throw ServerException();
    }
  }

  @override
  Future<String> refreshSession() async {
    try {
      final refreshToken = await _secureLocalStorage.load(key: 'refresh_token');
      if (refreshToken.trim().isEmpty) {
        throw AuthException();
      }

      final result = await _apiHelper.execute(
        method: Method.post,
        url: ApiConstants.refresh,
        data: {'refreshToken': refreshToken.trim()},
      );

      final accessToken = result['accessToken']?.toString() ?? '';
      final nextRefreshToken = result['refreshToken']?.toString() ?? '';

      if (accessToken.isEmpty) {
        throw AuthException();
      }

      await _secureLocalStorage.save(key: 'access_token', value: accessToken);
      if (nextRefreshToken.isNotEmpty) {
        await _secureLocalStorage.save(
          key: 'refresh_token',
          value: nextRefreshToken,
        );
      }

      return accessToken;
    } catch (e) {
      logger.e(e);
      throw AuthException();
    }
  }

  @override
  Future<void> register(RegisterModel model) async {
    try {
      await _apiHelper.execute(
        method: Method.post,
        url: ApiConstants.register,
        data: model.toJson(),
      );
      return;
    } on UnprocessableEntityException {
      // Backend thường trả 422 khi email đã tồn tại.
      throw DuplicateEmailException();
    } catch (e) {
      logger.e(e);
      throw ServerException();
    }
  }

  String? _extractUserIdFromAccessToken(String accessToken) {
    try {
      final parts = accessToken.split('.');
      if (parts.length < 2) {
        return null;
      }

      final payloadBase64 = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(payloadBase64));
      final decoded = jsonDecode(payload);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final userId = decoded['userId'] ?? decoded['sub'] ?? decoded['_id'];
      final idText = userId?.toString() ?? '';
      return idText.trim().isEmpty ? null : idText.trim();
    } catch (_) {
      return null;
    }
  }
}
