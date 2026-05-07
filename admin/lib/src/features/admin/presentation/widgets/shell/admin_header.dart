import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/dashboard/admin_dashboard_cubit.dart';
import '../../bloc/dashboard/admin_dashboard_state.dart';
import '../common/admin_section_meta.dart';

class AdminHeader extends StatelessWidget {
  final AdminDashboardState state;
  final VoidCallback? onMenuPressed;

  const AdminHeader({super.key, required this.state, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = adminSectionTitle(state.section);
    final subtitle = adminSectionSubtitle(state.section);
    final compact = onMenuPressed != null;
    final refreshEnabled = state.status != AdminDashboardStatus.loading;
    final refreshAction = refreshEnabled
        ? () => context.read<AdminDashboardCubit>().load()
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
      child: Row(
        children: [
          if (onMenuPressed != null) ...[
            IconButton(
              tooltip: 'M\u1EDF menu',
              onPressed: onMenuPressed,
              icon: const Icon(Icons.menu_open),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.displaySmall),
                const SizedBox(height: 8),
                Text(subtitle, style: textTheme.bodyLarge),
              ],
            ),
          ),
          const SizedBox(width: 16),
          compact
              ? IconButton(
                  tooltip: 'L\u00E0m m\u1EDBi',
                  onPressed: refreshAction,
                  icon: const Icon(Icons.refresh),
                )
              : OutlinedButton.icon(
                  onPressed: refreshAction,
                  icon: const Icon(Icons.refresh),
                  label: const Text('L\u00E0m m\u1EDBi'),
                ),
        ],
      ),
    );
  }
}
