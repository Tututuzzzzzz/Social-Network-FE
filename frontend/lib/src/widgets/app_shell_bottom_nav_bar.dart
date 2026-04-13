import 'dart:ui';

import 'package:flutter/material.dart';

class AppShellBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const AppShellBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const List<_BottomNavItem> _items = [
    _BottomNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home),
    _BottomNavItem(
      icon: Icons.smart_display_outlined,
      selectedIcon: Icons.smart_display,
    ),
    _BottomNavItem(icon: Icons.send_outlined, selectedIcon: Icons.send),
    _BottomNavItem(icon: Icons.person_outline, selectedIcon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewPadding.bottom;
    final navHeight = 74 + bottomInset;
    const navRadius = 30.0;
    const activeButtonSize = 44.0;

    return SizedBox(
      height: navHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomInset),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(navRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(navRadius),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0x7AFFFFFF), Color(0x63EFF2F7)],
                ),
                border: Border.all(color: const Color(0xFAFFFFFF), width: 0.95),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2AFFFFFF),
                    blurRadius: 10,
                    offset: Offset(0, -1),
                  ),
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 24,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.62),
                              Colors.white.withValues(alpha: 0.02),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(_items.length, (index) {
                      final item = _items[index];
                      final isSelected = index == selectedIndex;

                      return Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () => onTap(index),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOut,
                                  height: activeButtonSize,
                                  width: activeButtonSize,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0x85DCE3FF)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                    border: isSelected
                                        ? Border.all(
                                            color: const Color(0x88FFFFFF),
                                          )
                                        : null,
                                    boxShadow: isSelected
                                        ? const [
                                            BoxShadow(
                                              color: Color(0x12000000),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    isSelected ? item.selectedIcon : item.icon,
                                    size: 23,
                                    color: const Color(0xFF1B1B1F),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final IconData selectedIcon;

  const _BottomNavItem({required this.icon, required this.selectedIcon});
}
