import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_shell_bottom_nav_bar.dart';
import 'app_route_path.dart';

class AppShellPage extends StatelessWidget {
  final Widget body;

  const AppShellPage({super.key, required this.body});

  int _resolveSelectedTabIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith(AppRoutes.homeSearch.path)) {
      return 1;
    }
    if (location.startsWith(AppRoutes.reels.path)) {
      return 2;
    }
    if (location.startsWith(AppRoutes.chat.path)) {
      return 3;
    }
    if (location.startsWith(AppRoutes.profile.path)) {
      return 4;
    }

    return 0; // default home
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home.path);
        break;
      case 1:
        context.go(AppRoutes.homeSearch.path);
        break;
      case 2:
        context.go(AppRoutes.reels.path);
        break;
      case 3:
        context.go(AppRoutes.chat.path);
        break;
      case 4:
        context.go(AppRoutes.profile.path);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _resolveSelectedTabIndex(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(child: body),
          Align(
            alignment: Alignment.bottomCenter,
            child: AppShellBottomNavBar(
              selectedIndex: selectedIndex,
              onTap: (index) => _onDestinationSelected(context, index),
            ),
          ),
        ],
      ),
    );
  }
}
