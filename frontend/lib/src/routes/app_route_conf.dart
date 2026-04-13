import 'package:go_router/go_router.dart';

import 'app_route_path.dart';
import 'routes.dart';

class AppRoutesConf {
  GoRouter get router => _router;

  late final _router = GoRouter(
    initialLocation: AppRoutes.welcome.path,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.welcome.path,
        name: AppRoutes.welcome.name,
        builder: (context, state) => const WelcomeScreen(),
        routes: [
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
        ],
      ),
      GoRoute(
        path: AppRoutes.home.path,
        name: AppRoutes.home.name,
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: AppRoutes.postsFeed.path,
        name: AppRoutes.postsFeed.name,
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: AppRoutes.postsCreate.path,
        name: AppRoutes.postsCreate.name,
        builder: (context, state) => const CreatePostScreen(),
      ),
    ],
  );
}
