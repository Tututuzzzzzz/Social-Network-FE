import '../entities/admin_dashboard_snapshot.dart';
import '../repositories/admin_repository.dart';

class GetAdminDashboardUseCase {
  final AdminRepository _repository;

  const GetAdminDashboardUseCase(this._repository);

  Future<AdminDashboardSnapshot> call() {
    return _repository.getDashboardSnapshot();
  }
}
