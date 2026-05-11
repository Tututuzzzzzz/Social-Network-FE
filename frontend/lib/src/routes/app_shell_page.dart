import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../configs/injector/injector_conf.dart';
import '../core/realtime/realtime_socket_service.dart';
import '../core/theme/app_colors.dart';
import '../features/notifications/presentation/bloc/notification_bloc.dart';
import '../features/notifications/presentation/bloc/notification_event.dart';
import '../features/notifications/presentation/bloc/notification_state.dart';
import '../features/post/presentation/bloc/post/post_bloc.dart';
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
  bool _didLoadNotificationBadge = false;
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    // Socket connect ngay sau login — chạy 1 lần duy nhất.
    // ensureConnected() tự skip nếu đã connected.
    getIt<RealtimeSocketService>().ensureConnected();
    _notificationSubscription = getIt<RealtimeSocketService>()
        .notificationNewStream
        .listen((payload) {
      if (!mounted) return;
      context.read<NotificationBloc>().add(
        NotificationRealtimeReceived(payload),
      );
      _syncRealtimePostEngagement(payload);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didLoadNotificationBadge) return;
      _didLoadNotificationBadge = true;
      context.read<NotificationBloc>().add(
        const NotificationLoadRequested(unreadOnly: true),
      );
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _syncRealtimePostEngagement(Map<String, dynamic> payload) {
    final type = _readRealtimeText(payload, const ['type']).toUpperCase();
    final entityType = _readRealtimeText(
      payload,
      const ['entityType'],
    ).toUpperCase();
    final isLike = type.contains('LIKE') || entityType.contains('LIKE');
    final isComment =
        type.contains('COMMENT') || entityType.contains('COMMENT');

    if (!isLike && !isComment) return;

    final postId = _resolveRealtimePostId(payload);
    if (postId.isEmpty) return;

    getIt<PostBloc>().add(
      PostRealtimeEngagementChangedEvent(
        postId: postId,
        notificationId: _readRealtimeText(payload, const ['_id', 'id']),
        actorId: _resolveRealtimeActorId(payload),
        likeDelta: isLike ? 1 : 0,
        commentDelta: isComment ? 1 : 0,
      ),
    );
  }

  String _resolveRealtimePostId(Map<String, dynamic> payload) {
    final direct = _readRealtimeText(
      payload,
      const ['postId', 'post_id', 'entityId'],
    );
    if (direct.isNotEmpty) return direct;

    final postRaw = payload['post'];
    if (postRaw is Map) {
      return _readRealtimeText(
        Map<String, dynamic>.from(postRaw),
        const ['_id', 'id'],
      );
    }

    final dataRaw = payload['data'];
    if (dataRaw is Map) {
      return _resolveRealtimePostId(Map<String, dynamic>.from(dataRaw));
    }

    return '';
  }

  String _resolveRealtimeActorId(Map<String, dynamic> payload) {
    final direct = _readRealtimeText(payload, const ['actorId', 'userId']);
    if (direct.isNotEmpty) return direct;

    final actorRaw = payload['actorId'] ?? payload['actor'] ?? payload['user'];
    if (actorRaw is Map) {
      return _readRealtimeText(
        Map<String, dynamic>.from(actorRaw),
        const ['_id', 'id'],
      );
    }

    return actorRaw?.toString().trim() ?? '';
  }

  String _readRealtimeText(Map<String, dynamic> payload, List<String> keys) {
    for (final key in keys) {
      final value = payload[key];
      if (value == null) continue;
      if (value is Map) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }

    final dataRaw = payload['data'];
    if (dataRaw is Map) {
      return _readRealtimeText(Map<String, dynamic>.from(dataRaw), keys);
    }

    return '';
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
        context.read<NotificationBloc>().add(NotificationBadgeCleared());
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
      return widget.body;
    }

    final selectedIndex = _resolveSelectedTabIndex(context);

    return BlocBuilder<NotificationBloc, NotificationState>(
      buildWhen: (previous, current) =>
          previous.hasUnreadBadge != current.hasUnreadBadge,
      builder: (context, notificationState) {
        final colors = AppColors.of(context);
        return Scaffold(
          backgroundColor: colors.scaffold,
          body: widget.body,
          bottomNavigationBar: AppShellBottomNavBar(
            selectedIndex: selectedIndex,
            hasUnreadNotifications: notificationState.hasUnreadBadge,
            onTap: (index) => _onDestinationSelected(context, index),
          ),
        );
      },
    );
  }
}
