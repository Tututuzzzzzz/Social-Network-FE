import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/theme/app_colors.dart';

class ProfileSliverTabBar extends StatelessWidget {
  const ProfileSliverTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SliverPersistentHeader(
      pinned: true,
      delegate: _ProfileTabBarDelegate(
        TabBar(
          labelColor: colors.accent,
          unselectedLabelColor: colors.textSecondary,
          indicatorColor: colors.accent,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: context.l10n.postsLabel),
            Tab(text: context.l10n.photosLabel),
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
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.sheetSurface,
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: colors.scrim,
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
