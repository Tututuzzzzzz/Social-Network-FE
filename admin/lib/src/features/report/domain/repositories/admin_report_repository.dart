import '../entities/admin_report.dart';

abstract class AdminReportRepository {
  Future<List<AdminReport>> getReports();

  Future<void> resolveReport(String reportId);
}
