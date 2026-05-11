import 'package:flutter/material.dart';
import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';

class AppShellBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool hasUnreadNotifications;

  const AppShellBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.hasUnreadNotifications = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final List<_BottomNavItem> items = [
      _BottomNavItem(icon: Icons.home_rounded, label: l10n.navHome),
      _BottomNavItem(icon: Icons.add_box_outlined, label: l10n.navCreate),
      _BottomNavItem(
        icon: Icons.notifications_none_rounded,
        label: l10n.navNotifications,
        showBadge: hasUnreadNotifications,
      ),
      _BottomNavItem(icon: Icons.person_outline_rounded, label: l10n.navProfile),
    ];

    final colors = AppColors.of(context);

    final safeSelectedIndex = selectedIndex.clamp(0, items.length - 1).toInt();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.navBackground,
        border: Border(
          top: BorderSide(color: colors.navBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == safeSelectedIndex;
                final color =
                  isSelected ? colors.navActive : colors.navInactive;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(index),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 14,
                          right: 14,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            height: 3,
                            decoration: BoxDecoration(
                              color: isSelected ? colors.navActive : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedScale(
                                duration: const Duration(milliseconds: 180),
                                scale: isSelected ? 1.06 : 1.0,
                                curve: Curves.easeOut,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(
                                      item.icon,
                                      size: 28,
                                      color: color,
                                    ),
                                    if (item.showBadge)
                                      Positioned(
                                        top: 1,
                                        right: 1,
                                        child: Container(
                                          width: 9,
                                          height: 9,
                                          decoration: BoxDecoration(
                                            color: colors.badge,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: colors.badgeBorder,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.05,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: color,
                                ),
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final String label;
  final bool showBadge;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.showBadge = false,
  });
}
