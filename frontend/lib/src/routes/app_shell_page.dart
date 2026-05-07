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
