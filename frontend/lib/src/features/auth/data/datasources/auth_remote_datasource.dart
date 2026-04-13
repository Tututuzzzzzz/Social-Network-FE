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

      final token = result['accessToken']?.toString() ?? '';
      if (token.isEmpty) {
        throw ServerException();
      }

      await _secureLocalStorage.save(key: 'access_token', value: token);

      final profileResult = await _apiHelper.execute(
        method: Method.get,
        url: ApiConstants.profile,
      );

      final payload = profileResult['user'] ?? profileResult['data'] ?? result;
      if (payload is Map<String, dynamic>) {
        return UserModel.fromJson(payload);
      }

      if (payload is Map) {
        return UserModel.fromJson(Map<String, dynamic>.from(payload));
      }

      throw ServerException();
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
}
