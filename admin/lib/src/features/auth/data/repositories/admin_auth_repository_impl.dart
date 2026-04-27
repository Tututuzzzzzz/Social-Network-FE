import '../../domain/entities/admin_session.dart';
import '../../domain/repositories/admin_auth_repository.dart';
import '../datasources/admin_auth_remote_datasource.dart';

class AdminAuthRepositoryImpl implements AdminAuthRepository {
  final AdminAuthRemoteDataSource _remoteDataSource;

  const AdminAuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<AdminSession> login({
    required String username,
    required String password,
  }) {
    return _remoteDataSource.login(username: username, password: password);
  }

  @override
  Future<AdminSession?> restoreSession() {
    return _remoteDataSource.restoreSession();
  }

  @override
  Future<void> logout() {
    return _remoteDataSource.logout();
  }
}
