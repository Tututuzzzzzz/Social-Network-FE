import 'package:flutter/material.dart';

import '../../bloc/dashboard/admin_dashboard_state.dart';
import 'admin_content.dart';

class AdminCompactLayout extends StatelessWidget {
  final AdminDashboardState state;
  final VoidCallback onMenuPressed;

  const AdminCompactLayout({
    super.key,
    required this.state,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AdminContent(state: state, onMenuPressed: onMenuPressed);
  }
}
