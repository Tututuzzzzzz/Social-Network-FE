import '../entities/admin_report.dart';

abstract class AdminReportRepository {
  Future<List<AdminReport>> getReports();

  Future<List<AdminReport>> getReportsByPost(String postId);

  Future<void> reviewReport(String reportId, String status);
}
