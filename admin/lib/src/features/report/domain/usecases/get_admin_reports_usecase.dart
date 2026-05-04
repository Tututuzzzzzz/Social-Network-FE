import '../entities/admin_report.dart';
import '../repositories/admin_report_repository.dart';

class GetAdminReportsUseCase {
  final AdminReportRepository _repository;

  const GetAdminReportsUseCase(this._repository);

  Future<List<AdminReport>> call() {
    return _repository.getReports();
  }
}
