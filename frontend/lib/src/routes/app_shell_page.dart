import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_shell_bottom_nav_bar.dart';
import 'app_route_path.dart';

class AppShellPage extends StatelessWidget {
  final Widget body;

  const AppShellPage({super.key, required this.body});

  int _resolveSelectedTabIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith(AppRoutes.createPost.path)) {
      return 1;
    }
    if (location.startsWith(AppRoutes.notifications.path)) {
      return 2;
    }
    if (location.startsWith(AppRoutes.profile.path)) {
      return 3;
    }

    return 0; // default home
  }

  bool _shouldShowBottomNav(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return !location.startsWith(AppRoutes.homeSearch.path) &&
        !location.startsWith(AppRoutes.chat.path);
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home.path);
        break;
      case 1:
        context.go(AppRoutes.createPost.path);
        break;
      case 2:
        context.go(AppRoutes.notifications.path);
        break;
      case 3:
        context.go(AppRoutes.profile.path);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowBottomNav(context)) {
      return body;
    }

    final selectedIndex = _resolveSelectedTabIndex(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: body,
      bottomNavigationBar: AppShellBottomNavBar(
        selectedIndex: selectedIndex,
        onTap: (index) => _onDestinationSelected(context, index),
      ),
    );
  }
}
