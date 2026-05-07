import 'package:equatable/equatable.dart';
import '../../../post/domain/entities/admin_post.dart';
import '../../../report/domain/entities/admin_report.dart';
import '../../../user/domain/entities/admin_user.dart';
import 'admin_dashboard_metrics.dart';

class AdminDashboardSnapshot extends Equatable {
  final AdminDashboardMetrics metrics;
  final List<AdminUser> users;
  final List<AdminPost> posts;
  final List<AdminReport> reports;

  const AdminDashboardSnapshot({
    required this.metrics,
    required this.users,
    required this.posts,
    required this.reports,
  });

  static const empty = AdminDashboardSnapshot(
    metrics: AdminDashboardMetrics(
      usersCount: 0,
      postsCount: 0,
      reportsCount: 0,
      openReportsCount: 0,
    ),
    users: [],
    posts: [],
    reports: [],
  );

  @override
  List<Object?> get props => [metrics, users, posts, reports];
}
