import '../../domain/entities/admin_dashboard_metrics.dart';

class AdminDashboardMetricsModel extends AdminDashboardMetrics {
  const AdminDashboardMetricsModel({
    required super.usersCount,
    required super.postsCount,
    required super.reportsCount,
    required super.openReportsCount,
  });
}
