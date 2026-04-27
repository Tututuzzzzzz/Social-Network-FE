import 'package:flutter/material.dart';

import '../../bloc/dashboard/admin_dashboard_state.dart';
import 'admin_content.dart';
import 'admin_sidebar.dart';

class AdminWideLayout extends StatelessWidget {
  final AdminDashboardState state;

  const AdminWideLayout({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AdminSidebar(section: state.section),
        const VerticalDivider(width: 1),
        Expanded(child: AdminContent(state: state)),
      ],
    );
  }
}
