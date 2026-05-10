import 'package:flutter/material.dart';
import '../core/l10n/l10n.dart';

class AppShellBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const AppShellBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
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
      ),
      _BottomNavItem(icon: Icons.person_outline_rounded, label: l10n.navProfile),
    ];

    final safeSelectedIndex = selectedIndex.clamp(0, items.length - 1).toInt();

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E2E7), width: 1),
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
              final color = isSelected
                  ? const Color(0xFF2FC48F)
                  : const Color(0xFF8A8A90);

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
                              color: isSelected
                                  ? const Color(0xFF2FC48F)
                                  : Colors.transparent,
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
                                child: Icon(
                                  item.icon,
                                  size: 28,
                                  color: color,
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

  const _BottomNavItem({
    required this.icon,
    required this.label,
  });
}
