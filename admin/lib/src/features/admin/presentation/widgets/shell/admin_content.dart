import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/admin_dashboard_snapshot.dart';
import '../../bloc/dashboard/admin_dashboard_cubit.dart';
import '../../bloc/dashboard/admin_dashboard_state.dart';
import '../admin_empty_state.dart';
import '../overview/admin_overview_section.dart';
import '../posts/admin_posts_table.dart';
import '../reports/admin_reports_table.dart';
import '../users/admin_users_table.dart';
import 'admin_header.dart';

class AdminContent extends StatelessWidget {
  final AdminDashboardState state;

  const AdminContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: context.read<AdminDashboardCubit>().load,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: AdminHeader(state: state)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
              sliver: SliverToBoxAdapter(child: _AdminBody(state: state)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminBody extends StatelessWidget {
  final AdminDashboardState state;

  const _AdminBody({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.status == AdminDashboardStatus.loading &&
        state.snapshot == AdminDashboardSnapshot.empty) {
      return const SizedBox(
        height: 360,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == AdminDashboardStatus.failure) {
      return AdminEmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Không thể tải dữ liệu admin',
        message: state.message ?? 'Yêu cầu backend thất bại.',
      );
    }

    switch (state.section) {
      case AdminSection.overview:
        return AdminOverviewSection(snapshot: state.snapshot);
      case AdminSection.users:
        return AdminUsersTable(users: state.snapshot.users);
      case AdminSection.posts:
        return AdminPostsTable(
          posts: state.snapshot.posts,
          busyPostId: state.busyPostId,
        );
      case AdminSection.reports:
        return AdminReportsTable(
          reports: state.snapshot.reports,
          busyReportId: state.busyReportId,
        );
    }
  }
}
