import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/dashboard/admin_dashboard_cubit.dart';
import '../../bloc/dashboard/admin_dashboard_state.dart';

class AdminBottomNavigation extends StatelessWidget {
  final AdminSection section;

  const AdminBottomNavigation({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: AdminSection.values.indexOf(section),
      onDestinationSelected: (index) => context
          .read<AdminDashboardCubit>()
          .selectSection(AdminSection.values[index]),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Tổng quan',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_alt_outlined),
          label: 'Người dùng',
        ),
        NavigationDestination(
          icon: Icon(Icons.article_outlined),
          label: 'Bài viết',
        ),
        NavigationDestination(
          icon: Icon(Icons.flag_outlined),
          label: 'Báo cáo',
        ),
      ],
    );
  }
}
