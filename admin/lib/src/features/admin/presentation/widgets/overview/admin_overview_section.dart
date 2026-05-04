import 'package:flutter/material.dart';

import '../../../../post/presentation/widgets/admin_posts_table.dart';
import '../../../domain/entities/admin_dashboard_snapshot.dart';
import '../admin_metric_tile.dart';

class AdminOverviewSection extends StatelessWidget {
  final AdminDashboardSnapshot snapshot;

  const AdminOverviewSection({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 1200
                ? 4
                : width >= 760
                ? 2
                : 1;
            final metricTileExtent = crossAxisCount == 1 ? 184.0 : 204.0;

            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: metricTileExtent,
              ),
              children: [
                AdminMetricTile(
                  icon: Icons.people_alt_outlined,
                  label: 'Người dùng',
                  value: '${snapshot.metrics.usersCount}',
                  detail: 'Các tài khoản đang sử dụng Hệ thống',
                  color: const Color(0xFF0F766E),
                ),
                AdminMetricTile(
                  icon: Icons.article_outlined,
                  label: 'Bài viết',
                  value: '${snapshot.metrics.postsCount}',
                  detail: 'Mẫu feed mới nhất',
                  color: const Color(0xFF2563EB),
                ),
                AdminMetricTile(
                  icon: Icons.flag_outlined,
                  label: 'Báo cáo',
                  value: '${snapshot.metrics.reportsCount}',
                  detail: 'Các báo cáo về bài viết',
                  color: const Color(0xFFD97706),
                ),
                AdminMetricTile(
                  icon: Icons.priority_high_outlined,
                  label: 'Báo cáo',
                  value: '${snapshot.metrics.openReportsCount}',
                  detail: 'Đang chờ xem xét',
                  color: const Color(0xFFB42318),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        AdminPostsTable(posts: snapshot.posts.take(6).toList()),
      ],
    );
  }
}
