import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/presentation/bloc/auth/admin_auth_cubit.dart';
import '../../../../auth/presentation/bloc/auth/admin_auth_state.dart';
import '../../bloc/dashboard/admin_dashboard_cubit.dart';
import '../../bloc/dashboard/admin_dashboard_state.dart';

class AdminSidebar extends StatelessWidget {
  final AdminSection section;

  const AdminSidebar({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final session = context.select<AdminAuthCubit, _AdminSessionView>(
      (cubit) => _AdminSessionView.fromState(cubit.state),
    );

    return Container(
      width: 248,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shield, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mochi Admin',
                  style: textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _SectionButton(
            icon: Icons.dashboard_outlined,
            label: 'Tổng quan',
            selected: section == AdminSection.overview,
            onTap: () => context.read<AdminDashboardCubit>().selectSection(
              AdminSection.overview,
            ),
          ),
          _SectionButton(
            icon: Icons.people_alt_outlined,
            label: 'Người dùng',
            selected: section == AdminSection.users,
            onTap: () => context.read<AdminDashboardCubit>().selectSection(
              AdminSection.users,
            ),
          ),
          _SectionButton(
            icon: Icons.article_outlined,
            label: 'Bài viết',
            selected: section == AdminSection.posts,
            onTap: () => context.read<AdminDashboardCubit>().selectSection(
              AdminSection.posts,
            ),
          ),
          _SectionButton(
            icon: Icons.flag_outlined,
            label: 'Báo cáo',
            selected: section == AdminSection.reports,
            onTap: () => context.read<AdminDashboardCubit>().selectSection(
              AdminSection.reports,
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5EF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE6E0D5)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: const Color(0xFF17211D),
                  child: Text(
                    session.initial,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    session.username,
                    style: textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Đăng xuất',
                  onPressed: () => context.read<AdminAuthCubit>().logout(),
                  icon: const Icon(Icons.logout, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SectionButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = selected ? colorScheme.primary : const Color(0xFF56645E);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary.withValues(alpha: .1) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: foreground),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminSessionView {
  final String username;
  final String initial;

  const _AdminSessionView({required this.username, required this.initial});

  factory _AdminSessionView.fromState(AdminAuthState state) {
    final username = state.session?.username ?? 'admin';
    final initial = username.trim().isEmpty
        ? 'A'
        : username.trim().substring(0, 1).toUpperCase();

    return _AdminSessionView(username: username, initial: initial);
  }
}
