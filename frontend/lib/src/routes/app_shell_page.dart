import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../configs/injector/injector_conf.dart';
import '../core/realtime/realtime_socket_service.dart';
import '../widgets/app_shell_bottom_nav_bar.dart';
import 'app_route_path.dart';

/// Shell chung cho các trang đã login.
///
/// Kết nối socket ngay khi mount (= sau login thành công).
/// Không disconnect khi dispose vì singleton sống xuyên suốt session.
class AppShellPage extends StatefulWidget {
  final Widget body;

  const AppShellPage({super.key, required this.body});

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  @override
  void initState() {
    super.initState();
    // Socket connect ngay sau login — chạy 1 lần duy nhất.
    // ensureConnected() tự skip nếu đã connected.
    getIt<RealtimeSocketService>().ensureConnected();
  }

  int _resolveSelectedTabIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith(AppRoutes.homeSearch.path)) {
      return 1;
    }
    if (location.startsWith(AppRoutes.chat.path)) {
      return 2;
    }
    if (location.startsWith(AppRoutes.profile.path)) {
      return 3;
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
        context.go(AppRoutes.chat.path);
        break;
      case 3:
        context.go(AppRoutes.profile.path);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _resolveSelectedTabIndex(context);

    return Material(
      color: Colors.white,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: widget.body),
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
