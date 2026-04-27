import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/dashboard/admin_dashboard_cubit.dart';
import '../../bloc/dashboard/admin_dashboard_state.dart';
import '../common/admin_section_meta.dart';

class AdminHeader extends StatelessWidget {
  final AdminDashboardState state;

  const AdminHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = adminSectionTitle(state.section);
    final subtitle = adminSectionSubtitle(state.section);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
      child: Row(
        children: [
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
          OutlinedButton.icon(
            onPressed: state.status == AdminDashboardStatus.loading
                ? null
                : () => context.read<AdminDashboardCubit>().load(),
            icon: const Icon(Icons.refresh),
            label: const Text('Làm mới'),
          ),
        ],
      ),
    );
  }
}
