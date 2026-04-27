import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/cache/session_storage.dart';
import '../models/admin_session_model.dart';

abstract class AdminAuthRemoteDataSource {
  Future<AdminSessionModel> login({
    required String username,
    required String password,
  });

  Future<AdminSessionModel?> restoreSession();

  Future<void> logout();
}

class AdminAuthRemoteDataSourceImpl implements AdminAuthRemoteDataSource {
  final ApiClient _apiClient;
  final SessionStorage _sessionStorage;

  const AdminAuthRemoteDataSourceImpl(this._apiClient, this._sessionStorage);

  @override
  Future<AdminSessionModel> login({
    required String username,
    required String password,
  }) async {
    final result = await _apiClient.post(
      ApiConstants.login,
      data: {'username': username, 'password': password},
    );

    if (result is! Map) {
      throw const ApiException('Phan hoi dang nhap khong hop le');
    }

    final session = AdminSessionModel.fromLoginResponse(
      Map<String, dynamic>.from(result),
    );

    if (session.accessToken.trim().isEmpty) {
      throw const ApiException('Backend khong tra access token');
    }

    await _sessionStorage.saveAccessToken(session.accessToken);
    return session;
  }

  @override
  Future<AdminSessionModel?> restoreSession() async {
    final token = await _sessionStorage.readAccessToken();
    if (token == null) {
      return null;
    }

    return AdminSessionModel.fromToken(token);
  }

  @override
  Future<void> logout() {
    return _sessionStorage.clear();
  }
}
