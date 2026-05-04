import 'package:flutter/material.dart';

import '../../bloc/dashboard/admin_dashboard_state.dart';
import 'admin_content.dart';
import 'admin_sidebar.dart';

class AdminWideLayout extends StatelessWidget {
  final AdminDashboardState state;
  final bool sidebarExpanded;
  final VoidCallback onToggleSidebar;

  const AdminWideLayout({
    super.key,
    required this.state,
    required this.sidebarExpanded,
    required this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AdminSidebar(
          section: state.section,
          expanded: sidebarExpanded,
          onToggle: onToggleSidebar,
        ),
        const VerticalDivider(width: 1),
        Expanded(child: AdminContent(state: state)),
      ],
    );
  }
}
