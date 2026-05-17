import '../entities/admin_report.dart';
import '../repositories/admin_report_repository.dart';

class GetAdminReportsByPostUseCase {
  final AdminReportRepository _repository;

  const GetAdminReportsByPostUseCase(this._repository);

  Future<List<AdminReport>> call(String postId) {
    return _repository.getReportsByPost(postId);
  }
}
