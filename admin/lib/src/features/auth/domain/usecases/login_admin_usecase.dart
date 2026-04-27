import '../entities/admin_session.dart';
import '../repositories/admin_auth_repository.dart';

class LoginAdminUseCase {
  final AdminAuthRepository _repository;

  const LoginAdminUseCase(this._repository);

  Future<AdminSession> call({
    required String username,
    required String password,
  }) {
    return _repository.login(username: username, password: password);
  }
}
