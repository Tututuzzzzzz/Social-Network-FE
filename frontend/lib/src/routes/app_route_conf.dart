import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../configs/injector/injector_conf.dart';
import '../features/chat/domain/entities/chat_entity.dart';
import '../features/message/presentation/bloc/message_bloc.dart';
import '../features/notifications/presentation/bloc/notification_bloc.dart';
import '../features/post/presentation/bloc/post/post_bloc.dart';
import '../features/profile/presentation/bloc/profile/profile_bloc.dart';
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
      GoRoute(
        path: AppRoutes.home.path,
        name: AppRoutes.home.name,
        builder: (context, state) => BlocProvider<PostBloc>(
          create: (_) => getIt<PostBloc>(),
          child: const FeedScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.homeSearch.path,
        name: AppRoutes.homeSearch.name,
        builder: (context, state) => BlocProvider<PostBloc>(
          create: (_) => getIt<PostBloc>(),
          child: const FeedScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.reels.path,
        name: AppRoutes.reels.name,
        builder: (context, state) => const AppShellPage(body: MochiReelsPage()),
      ),
      GoRoute(
        path: AppRoutes.chat.path,
        name: AppRoutes.chat.name,
        builder: (context, state) =>
            const AppShellPage(body: MochiDirectMessagesPage()),
      ),
      GoRoute(
        path: AppRoutes.notifications.path,
        name: AppRoutes.notifications.name,
        builder: (context, state) => BlocProvider<NotificationBloc>(
          create: (_) => getIt<NotificationBloc>(),
          child: NotificationScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.profile.path,
        name: AppRoutes.profile.name,
        builder: (context, state) => BlocProvider<ProfileBloc>(
          create: (_) => getIt<ProfileBloc>(),
          child: const AppShellPage(body: MochiProfilePage()),
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfile.path,
        name: AppRoutes.editProfile.name,
        builder: (context, state) => const EditProfilePage(),
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
          return BlocProvider<MessageBloc>(
            create: (_) => getIt<MessageBloc>(),
            child: MessageChatRoomPage(thread: thread),
          );
        },
      ),
    ],
  );
}
