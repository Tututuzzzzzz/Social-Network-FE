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
      if (accessToken.isEmpty) {
        throw ServerException();
      }
      await _secureLocalStorage.save(key: 'access_token', value: accessToken);

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
      await _secureLocalStorage.delete(key: 'access_token');
      await Future.delayed(const Duration(seconds: 1));
      return;
    } catch (e) {
      logger.e(e);
      throw ServerException();
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
