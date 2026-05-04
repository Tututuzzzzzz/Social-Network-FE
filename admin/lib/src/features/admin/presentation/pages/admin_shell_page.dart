import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard/admin_dashboard_cubit.dart';
import '../bloc/dashboard/admin_dashboard_state.dart';
import '../widgets/shell/admin_compact_layout.dart';
import '../widgets/shell/admin_sidebar.dart';
import '../widgets/shell/admin_wide_layout.dart';

class AdminShellPage extends StatefulWidget {
  const AdminShellPage({super.key});

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  bool _sidebarExpanded = true;

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
              drawer: compact
                  ? Drawer(
                      width: 248,
                      child: AdminSidebar(
                        section: state.section,
                        onSectionSelected: () =>
                            Navigator.of(context).maybePop(),
                      ),
                    )
                  : null,
              body: compact
                  ? Builder(
                      builder: (scaffoldContext) => AdminCompactLayout(
                        state: state,
                        onMenuPressed: () =>
                            Scaffold.of(scaffoldContext).openDrawer(),
                      ),
                    )
                  : AdminWideLayout(
                      state: state,
                      sidebarExpanded: _sidebarExpanded,
                      onToggleSidebar: () => setState(() {
                        _sidebarExpanded = !_sidebarExpanded;
                      }),
                    ),
            );
          },
        );
      },
    );
  }
}
