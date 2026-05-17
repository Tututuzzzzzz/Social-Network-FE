import '../repositories/admin_report_repository.dart';

class ResolveAdminReportUseCase {
  final AdminReportRepository _repository;

  const ResolveAdminReportUseCase(this._repository);

  Future<void> call(String reportId, {String status = 'resolved'}) {
    return _repository.reviewReport(reportId, status);
  }
}
