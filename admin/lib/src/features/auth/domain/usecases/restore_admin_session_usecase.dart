import '../entities/admin_session.dart';
import '../repositories/admin_auth_repository.dart';

class RestoreAdminSessionUseCase {
  final AdminAuthRepository _repository;

  const RestoreAdminSessionUseCase(this._repository);

  Future<AdminSession?> call() {
    return _repository.restoreSession();
  }
}
