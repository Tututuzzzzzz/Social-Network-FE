import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../configs/injector/injector_conf.dart';
import '../features/chat/domain/entities/chat_entity.dart';
import '../features/message/presentation/bloc/message_bloc.dart';
import '../features/message/presentation/pages/conversation_management_page.dart';
import '../features/notifications/presentation/bloc/notification_bloc.dart';
import '../features/post/presentation/bloc/post/post_bloc.dart';
import '../features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'app_route_path.dart';
import 'app_shell_page.dart';
import 'routes.dart';

class AppRoutesConf {
  static const String _startRoute = String.fromEnvironment('START_ROUTE');

  GoRouter get router => _router;

  String _resolveInitialLocation() {
    if (_startRoute.isEmpty) {
      return AppRoutes.onboarding.path;
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
        path: AppRoutes.onboarding.path,
        name: AppRoutes.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
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
        path: AppRoutes.forgotPassword.path,
        name: AppRoutes.forgotPassword.name,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.verificationCode.path,
        name: AppRoutes.verificationCode.name,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerificationCodeScreen(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword.path,
        name: AppRoutes.resetPassword.name,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerSuccess.path,
        name: AppRoutes.registerSuccess.name,
        builder: (context, state) => const RegisterSuccessScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShellPage(body: child),
        routes: [
          GoRoute(
            path: AppRoutes.home.path,
            name: AppRoutes.home.name,
            builder: (context, state) => BlocProvider.value(
              value: getIt<PostBloc>(),
              child: const FeedScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.homeSearch.path,
            name: AppRoutes.homeSearch.name,
            builder: (context, state) => const MochiSearchPage(),
          ),
          GoRoute(
            path: AppRoutes.chat.path,
            name: AppRoutes.chat.name,
            builder: (context, state) => const MochiDirectMessagesPage(),
          ),
          GoRoute(
            path: AppRoutes.profile.path,
            name: AppRoutes.profile.name,
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<ProfileBloc>(),
              child: const MochiProfilePage(),
            ),
          ),

          GoRoute(
            path: AppRoutes.notifications.path,
            name: AppRoutes.notifications.name,
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<NotificationBloc>(),
              child: const NotificationScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.createPost.path,
        name: AppRoutes.createPost.name,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: getIt<PostBloc>()),
            BlocProvider(create: (_) => getIt<ProfileBloc>()),
          ],
          child: const CreatePostScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.chatNewConversation.path,
        name: AppRoutes.chatNewConversation.name,
        builder: (context, state) => const MochiNewConversationPage(),
      ),
      GoRoute(
        path: AppRoutes.editProfile.path,
        name: AppRoutes.editProfile.name,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.otherProfile.path,
        name: AppRoutes.otherProfile.name,
        builder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          return BlocProvider(
            create: (_) => getIt<ProfileBloc>(),
            child: MochiProfilePage(userId: userId),
          );
        },
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
          return BlocProvider(
            create: (_) => getIt<MessageBloc>(),
            child: MessageChatRoomPage(thread: thread),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.chatConversationManage.path,
        name: AppRoutes.chatConversationManage.name,
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
          return ConversationManagementPage(thread: thread);
        },
      ),
    ],
  );
}
