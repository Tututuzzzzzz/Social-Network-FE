import '../../domain/entities/admin_dashboard_snapshot.dart';
import '../../../post/domain/entities/admin_post.dart';
import '../../../report/domain/entities/admin_report.dart';
import '../../../user/domain/entities/admin_user.dart';
import 'admin_dashboard_metrics_model.dart';

class AdminDashboardSnapshotModel extends AdminDashboardSnapshot {
  const AdminDashboardSnapshotModel({
    required super.metrics,
    required super.users,
    required super.posts,
    required super.reports,
  });

  factory AdminDashboardSnapshotModel.fromCollections({
    required List<AdminUser> users,
    required List<AdminPost> posts,
    required List<AdminReport> reports,
  }) {
    final openReports = reports.where((report) => report.isOpen).length;

    return AdminDashboardSnapshotModel(
      metrics: AdminDashboardMetricsModel(
        usersCount: users.length,
        postsCount: posts.length,
        reportsCount: reports.length,
        openReportsCount: openReports,
      ),
      users: users,
      posts: posts,
      reports: reports,
    );
  }
}
