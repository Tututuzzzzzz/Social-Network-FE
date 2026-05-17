import '../../domain/entities/admin_report.dart';
import '../../domain/repositories/admin_report_repository.dart';
import '../datasources/admin_report_remote_datasource.dart';

class AdminReportRepositoryImpl implements AdminReportRepository {
  final AdminReportRemoteDataSource _remoteDataSource;

  const AdminReportRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AdminReport>> getReports() {
    return _remoteDataSource.fetchReports();
  }

  @override
  Future<List<AdminReport>> getReportsByPost(String postId) {
    return _remoteDataSource.fetchReportsByPost(postId);
  }

  @override
  Future<void> reviewReport(String reportId, String status) {
    return _remoteDataSource.reviewReport(reportId, status);
  }
}
