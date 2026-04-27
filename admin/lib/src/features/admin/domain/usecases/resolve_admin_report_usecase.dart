import '../repositories/admin_repository.dart';

class ResolveAdminReportUseCase {
  final AdminRepository _repository;

  const ResolveAdminReportUseCase(this._repository);

  Future<void> call(String reportId) {
    return _repository.resolveReport(reportId);
  }
}
