import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard/admin_dashboard_cubit.dart';
import '../bloc/dashboard/admin_dashboard_state.dart';
import '../widgets/shell/admin_bottom_navigation.dart';
import '../widgets/shell/admin_compact_layout.dart';
import '../widgets/shell/admin_wide_layout.dart';

class AdminShellPage extends StatelessWidget {
  const AdminShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminDashboardCubit, AdminDashboardState>(
      listenWhen: (previous, current) => previous.message != current.message,
      listener: (context, state) {
        final message = state.message;
        if (message == null || message.trim().isEmpty) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 920;

            return Scaffold(
              body: compact
                  ? AdminCompactLayout(state: state)
                  : AdminWideLayout(state: state),
              bottomNavigationBar: compact
                  ? AdminBottomNavigation(section: state.section)
                  : null,
            );
          },
        );
      },
    );
  }
}
