import 'package:flutter/material.dart';

class ProfileSliverTabBar extends StatelessWidget {
  const ProfileSliverTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _ProfileTabBarDelegate(
        const TabBar(
          labelColor: Color(0xFF20A87B),
          unselectedLabelColor: Color(0xFF66716D),
          indicatorColor: Color(0xFF20A87B),
          indicatorWeight: 2.5,
          labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          unselectedLabelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: 'Bài Viết'),
            Tab(text: 'Ảnh'),
          ],
        ),
      ),
    );
  }
}

class _ProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  _ProfileTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _ProfileTabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar;
  }
}
