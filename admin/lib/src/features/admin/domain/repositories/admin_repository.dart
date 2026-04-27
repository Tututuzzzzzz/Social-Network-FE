import '../entities/admin_dashboard_snapshot.dart';

abstract class AdminRepository {
  Future<AdminDashboardSnapshot> getDashboardSnapshot();

  Future<void> deletePost(String postId);

  Future<void> resolveReport(String reportId);
}
