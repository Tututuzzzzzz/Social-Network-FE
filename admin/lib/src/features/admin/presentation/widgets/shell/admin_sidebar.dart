import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/presentation/bloc/auth/admin_auth_cubit.dart';
import '../../../../auth/presentation/bloc/auth/admin_auth_state.dart';
import '../../bloc/dashboard/admin_dashboard_cubit.dart';
import '../../bloc/dashboard/admin_dashboard_state.dart';

class AdminSidebar extends StatelessWidget {
  final AdminSection section;
  final bool expanded;
  final VoidCallback? onToggle;
  final VoidCallback? onSectionSelected;

  const AdminSidebar({
    super.key,
    required this.section,
    this.expanded = true,
    this.onToggle,
    this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final session = context.select<AdminAuthCubit, _AdminSessionView>(
      (cubit) => _AdminSessionView.fromState(cubit.state),
    );

    void selectSection(AdminSection target) {
      context.read<AdminDashboardCubit>().selectSection(target);
      onSectionSelected?.call();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: expanded ? 248 : 82,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        expanded ? 18 : 12,
        18,
        expanded ? 18 : 12,
        22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          expanded
              ? Row(
                  children: [
                    const _BrandMark(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Mochi Admin',
                        style: textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onToggle != null)
                      IconButton(
                        tooltip: 'Thu g\u1ECDn menu',
                        onPressed: onToggle,
                        icon: const Icon(Icons.chevron_left),
                      ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(child: _BrandMark()),
                    if (onToggle != null) ...[
                      const SizedBox(height: 10),
                      IconButton(
                        tooltip: 'M\u1EDF r\u1ED9ng menu',
                        onPressed: onToggle,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ],
                ),
          SizedBox(height: expanded ? 28 : 20),
          _SectionButton(
            icon: Icons.dashboard_outlined,
            label: 'T\u1ED5ng quan',
            expanded: expanded,
            selected: section == AdminSection.overview,
            onTap: () => selectSection(AdminSection.overview),
          ),
          _SectionButton(
            icon: Icons.people_alt_outlined,
            label: 'Ng\u01B0\u1EDDi d\u00F9ng',
            expanded: expanded,
            selected: section == AdminSection.users,
            onTap: () => selectSection(AdminSection.users),
          ),
          _SectionButton(
            icon: Icons.article_outlined,
            label: 'B\u00E0i vi\u1EBFt',
            expanded: expanded,
            selected: section == AdminSection.posts,
            onTap: () => selectSection(AdminSection.posts),
          ),
          _SectionButton(
            icon: Icons.flag_outlined,
            label: 'B\u00E1o c\u00E1o',
            expanded: expanded,
            selected: section == AdminSection.reports,
            onTap: () => selectSection(AdminSection.reports),
          ),
          const Spacer(),
          expanded
              ? Container(
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
                        tooltip: '\u0110\u0103ng xu\u1EA5t',
                        onPressed: () =>
                            context.read<AdminAuthCubit>().logout(),
                        icon: const Icon(Icons.logout, size: 20),
                      ),
                    ],
                  ),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F5EF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE6E0D5)),
                  ),
                  child: Column(
                    children: [
                      Tooltip(
                        message: session.username,
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor: const Color(0xFF17211D),
                          child: Text(
                            session.initial,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        tooltip: '\u0110\u0103ng xu\u1EA5t',
                        onPressed: () =>
                            context.read<AdminAuthCubit>().logout(),
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

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF0F766E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.shield, color: Colors.white),
    );
  }
}

class _SectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool expanded;
  final bool selected;
  final VoidCallback onTap;

  const _SectionButton({
    required this.icon,
    required this.label,
    required this.expanded,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = selected ? colorScheme.primary : const Color(0xFF56645E);

    final button = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          padding: expanded
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
              : const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary.withValues(alpha: .1) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: expanded
              ? Row(
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
                )
              : Center(child: Icon(icon, size: 20, color: foreground)),
        ),
      ),
    );

    return expanded ? button : Tooltip(message: label, child: button);
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
