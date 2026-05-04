import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppShellBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const AppShellBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const String _homeSvg = '''<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-house-icon lucide-house"><path d="M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8"/><path d="M3 10a2 2 0 0 1 .709-1.528l7-6a2 2 0 0 1 2.582 0l7 6A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>''';
  static const String _searchSvg = '''<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-search-icon lucide-search"><path d="m21 21-4.34-4.34"/><circle cx="11" cy="11" r="8"/></svg>''';
  static const String _sendSvg = '''<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-send-icon lucide-send"><path d="M14.536 21.686a.5.5 0 0 0 .937-.024l6.5-19a.496.496 0 0 0-.635-.635l-19 6.5a.5.5 0 0 0-.024.937l7.93 3.18a2 2 0 0 1 1.112 1.11z"/><path d="m21.854 2.147-10.94 10.939"/></svg>''';

  static const List<_BottomNavItem> _items = [
    _BottomNavItem(svgIcon: _homeSvg),
    _BottomNavItem(svgIcon: _searchSvg),
    _BottomNavItem(svgIcon: _sendSvg),
    _BottomNavItem(isAvatar: true),
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewPadding.bottom;
    const navHeight = 79.0;
    const navWidth = 375.0;
    const navRadius = 50.0;
    const activeButtonSize = 69.0;

    return Container(
      width: double.infinity,
      height: navHeight + bottomInset + 12,
      padding: EdgeInsets.only(bottom: bottomInset + 12),
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: navHeight,
        width: navWidth,
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
                  colors: [Color(0x4DFFFFFF), Color(0x33EFF2F7)],
                ),
                border: Border.all(color: const Color(0x80FFFFFF), width: 0.95),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(_items.length, (index) {
                  final item = _items[index];
                  final isSelected = index == selectedIndex;

                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () => onTap(index),
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            height: activeButtonSize,
                            width: activeButtonSize,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE2E9FF)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
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
                            child: item.isAvatar
                                ? ClipOval(
                                    child: Image.asset(
                                      'assets/images/logo1.jpg',
                                      width: 28,
                                      height: 28,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(
                                        Icons.person,
                                        size: 28,
                                        color: Color(0xFF1B1B1F),
                                      ),
                                    ),
                                  )
                                : item.svgIcon != null
                                    ? SvgPicture.string(
                                        item.svgIcon!,
                                        width: 28,
                                        height: 28,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFF1B1B1F),
                                          BlendMode.srcIn,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  final String? svgIcon;
  final bool isAvatar;

  const _BottomNavItem({
    this.svgIcon,
    this.isAvatar = false,
  });
}
