import '../repositories/admin_auth_repository.dart';

class LogoutAdminUseCase {
  final AdminAuthRepository _repository;

  const LogoutAdminUseCase(this._repository);

  Future<void> call() {
    return _repository.logout();
  }
}
