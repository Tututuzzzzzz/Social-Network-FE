import 'package:go_router/go_router.dart';

import '../features/chat/domain/entities/chat_entity.dart';
import 'app_shell_page.dart';
import 'app_route_path.dart';
import 'routes.dart';

class AppRoutesConf {
  static const String _startRoute = String.fromEnvironment('START_ROUTE');

  GoRouter get router => _router;

  String _resolveInitialLocation() {
    if (_startRoute.isEmpty) {
      return AppRoutes.welcome.path;
    }

    final isKnownStaticRoute = AppRoutes.values.any(
      (route) => !route.path.contains(':') && route.path == _startRoute,
    );

    if (isKnownStaticRoute) {
      return _startRoute;
    }

    if (_startRoute.startsWith('/chat/room/')) {
      return _startRoute;
    }

    return AppRoutes.welcome.path;
  }

  late final GoRouter _router = GoRouter(
    initialLocation: _resolveInitialLocation(),
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.welcome.path,
        name: AppRoutes.welcome.name,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login.path,
        name: AppRoutes.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register.path,
        name: AppRoutes.register.name,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth.path,
        name: AppRoutes.auth.name,
        redirect: (context, state) {
          if (state.matchedLocation == AppRoutes.auth.path) {
            return AppRoutes.authLogin.path;
          }
          return null;
        },
        routes: [
          GoRoute(
            path: 'login',
            name: AppRoutes.authLogin.name,
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: 'register',
            name: AppRoutes.authRegister.name,
            builder: (context, state) => const RegisterScreen(),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home.path,
                name: AppRoutes.home.name,
                builder: (context, state) => const MochiMainPage(),
                routes: [
                  GoRoute(
                    path: 'search',
                    name: AppRoutes.homeSearch.name,
                    builder: (context, state) => const MochiSearchPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reels.path,
                name: AppRoutes.reels.name,
                builder: (context, state) => const MochiReelsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.chat.path,
                name: AppRoutes.chat.name,
                builder: (context, state) => const MochiDirectMessagesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile.path,
                name: AppRoutes.profile.name,
                builder: (context, state) => const MochiProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.chatMochiChatRoom.path,
        name: AppRoutes.chatMochiChatRoom.name,
        builder: (context, state) {
          final threadId = state.pathParameters['threadId'] ?? '';
          final extra = state.extra;
          final thread = extra is ChatEntity
              ? extra
              : ChatEntity(
                  id: threadId,
                  senderName: 'Conversation',
                  messagePreview: 'Start chatting',
                );
          return MochiChatRoomPage(thread: thread);
        },
      ),
    ],
  );
}
