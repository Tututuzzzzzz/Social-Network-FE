import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../configs/injector/injector_conf.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/failure_converter.dart';
import '../../../chat/domain/entities/chat_entity.dart';
import '../../../post/domain/entities/post_entity.dart';
import '../../../post/domain/usecases/get_post_by_id_usecase.dart';
import '../../../post/presentation/bloc/post/post_bloc.dart';
import '../../../post/presentation/pages/post_detail_screen.dart';
import '../../../../routes/app_route_path.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String? _openingPostNotificationId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationBloc>().add(const NotificationLoadRequested());
    });
  }

  Future<void> _onRefresh() async {
    context.read<NotificationBloc>().add(
      const NotificationLoadRequested(refresh: true),
    );
  }

  bool _isFriendRequest(NotificationEntity item) =>
      item.type.toUpperCase() == 'FRIEND_REQUEST';

  bool _isMessageNotification(NotificationEntity item) =>
      item.type.toUpperCase() == 'MESSAGE_NEW';

  bool _isPostNotification(NotificationEntity item) =>
      !_isFriendRequest(item) && !_isMessageNotification(item);

  bool _isGroupMessage(NotificationEntity item) {
    final title = item.title.toLowerCase();
    return title.contains('nhom');
  }

  String _resolvePostId(NotificationEntity item) {
    final entityId = item.entityId?.trim() ?? '';
    if (entityId.isEmpty || _isFriendRequest(item)) {
      return '';
    }

    final type = item.type.toUpperCase();
    final entityType = (item.entityType ?? '').toUpperCase();
    if (type.contains('POST') || entityType.contains('POST')) {
      return entityId;
    }

    // Current backend groups all non-friend notifications under post updates.
    return entityId;
  }

  String _resolveConversationId(NotificationEntity item) {
    if (!_isMessageNotification(item)) {
      return '';
    }

    return item.entityId?.trim() ?? '';
  }

  void _markAsReadIfNeeded(NotificationEntity item) {
    if (item.isRead) return;
    context.read<NotificationBloc>().add(
      NotificationMarkAsReadRequested(item.id),
    );
  }

  void _openActorProfile(NotificationEntity item) {
    final actorId = item.actorId.trim();
    if (actorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.l10n.userDefaultName} không có thông tin'),
        ),
      );
      return;
    }
    
    context.pushNamed(
      AppRoutes.otherProfile.name,
      pathParameters: {'userId': actorId},
    );
  }

  PostEntity? _findLoadedPost(String postId, PostBloc postBloc) {
    final state = postBloc.state;
    if (state is! PostLoadedState) return null;

    for (final post in state.posts) {
      if (post.id == postId) {
        return post;
      }
    }

    return null;
  }

  Future<void> _openMessageNotification(NotificationEntity item) async {
    _markAsReadIfNeeded(item);

    final conversationId = _resolveConversationId(item);
    if (conversationId.isEmpty) {
      _openActorProfile(item);
      return;
    }

    final thread = ChatEntity(
      id: conversationId,
      senderName: item.actorName.trim().isEmpty
          ? context.l10n.conversationTitle
          : item.actorName,
      messagePreview: item.body,
      avatarUrl: item.actorAvatarUrl,
      isGroup: _isGroupMessage(item),
    );

    if (!mounted) return;

    context.pushNamed(
      AppRoutes.chatMochiChatRoom.name,
      pathParameters: {'threadId': conversationId},
      extra: thread,
    );
  }

  Future<void> _openPostNotification(NotificationEntity item) async {
    if (_openingPostNotificationId != null) return;

    if (_isMessageNotification(item)) {
      await _openMessageNotification(item);
      return;
    }

    _markAsReadIfNeeded(item);

    final postId = _resolvePostId(item);
    if (postId.isEmpty) {
      _openActorProfile(item);
      return;
    }

    final postBloc = getIt<PostBloc>();
    final loadedPost = _findLoadedPost(postId, postBloc);
    if (loadedPost != null) {
      _pushPostDetail(loadedPost, postBloc);
      return;
    }

    setState(() {
      _openingPostNotificationId = item.id;
    });

    final result = await getIt<GetPostByIdUseCase>().call(
      GetPostByIdParams(postId: postId),
    );

    if (!mounted) return;

    setState(() {
      _openingPostNotificationId = null;
    });

    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mapFailureToMessage(failure))));
      },
      (post) {
        _pushPostDetail(post, postBloc);
      },
    );
  }

  void _pushPostDetail(PostEntity post, PostBloc postBloc) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: postBloc,
          child: PostDetailScreen(initialPost: post),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationBloc, NotificationState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        final message = state.errorMessage;
        if (message == null || message.isEmpty) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        final l10n = context.l10n;
        final colors = AppColors.of(context);
        final postNotifications = state.items
            .where(
              (item) =>
                  _isPostNotification(item) || _isMessageNotification(item),
            )
            .toList();
        final friendRequestNotifications = state.items
            .where(_isFriendRequest)
            .toList();

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: colors.scaffold,
            appBar: AppBar(
              backgroundColor: colors.appBar,
              foregroundColor: colors.appBarForeground,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                l10n.notificationsTitle,
                style: TextStyle(
                  color: colors.appBarForeground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // actions: [
              //   TextButton(
              //     onPressed: state.unreadCount == 0 || state.isSubmitting
              //         ? null
              //         : () {
              //             context.read<NotificationBloc>().add(
              //               NotificationMarkAllAsReadRequested(),
              //             );
              //           },
              //     child: Text(
              //       l10n.markAllAsRead,
              //       style: const TextStyle(color: Colors.white),
              //     ),
              //   ),
              // ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: colors.sheetSurface,
                  child: TabBar(
                    indicatorColor: colors.accent,
                    labelColor: colors.accent,
                    unselectedLabelColor: colors.textSecondary,
                    tabs: [
                      Tab(text: l10n.notificationTabPosts),
                      Tab(text: l10n.notificationTabFriends),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              children: [
                _NotificationListView(
                  items: postNotifications,
                  hasMore: state.hasMore,
                  emptyMessage: l10n.notificationEmptyPosts,
                  onRefresh: _onRefresh,
                  onLoadMore: () {
                    context.read<NotificationBloc>().add(
                      NotificationLoadMoreRequested(),
                    );
                  },
                  itemBuilder: (item) => _NotificationTile(
                    item: item,
                    showFriendRequestActions: false,
                    isSubmitting: state.isSubmitting,
                    isOpening: _openingPostNotificationId == item.id,
                    onTap: () => _openPostNotification(item),
                  ),
                ),
                _NotificationListView(
                  items: friendRequestNotifications,
                  hasMore: state.hasMore,
                  emptyMessage: l10n.notificationEmptyFriends,
                  onRefresh: _onRefresh,
                  onLoadMore: () {
                    context.read<NotificationBloc>().add(
                      NotificationLoadMoreRequested(),
                    );
                  },
                  itemBuilder: (item) => _NotificationTile(
                    item: item,
                    showFriendRequestActions: true,
                    isSubmitting: state.isSubmitting,
                    isOpening: false,
                    onTap: () {
                      _markAsReadIfNeeded(item);
                      _openActorProfile(item);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationListView extends StatefulWidget {
  final List<NotificationEntity> items;
  final bool hasMore;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final Widget Function(NotificationEntity item) itemBuilder;

  const _NotificationListView({
    required this.items,
    required this.hasMore,
    required this.emptyMessage,
    required this.onRefresh,
    required this.onLoadMore,
    required this.itemBuilder,
  });

  @override
  State<_NotificationListView> createState() => _NotificationListViewState();
}

class _NotificationListViewState extends State<_NotificationListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !widget.hasMore) {
      return;
    }

    final threshold = _scrollController.position.maxScrollExtent - 120;
    if (_scrollController.position.pixels >= threshold) {
      widget.onLoadMore();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: widget.items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 180),
                Center(
                  child: Text(
                    widget.emptyMessage,
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              ],
            )
          : ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
              separatorBuilder: (_, _) => Divider(
                height: 1,
                thickness: 0.6,
                color: colors.subtleBorder,
              ),
              itemBuilder: (context, index) {
                if (index >= widget.items.length) {
                  return const SizedBox.shrink();
                }

                return widget.itemBuilder(widget.items[index]);
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity item;
  final bool showFriendRequestActions;
  final bool isSubmitting;
  final bool isOpening;
  final VoidCallback? onTap;

  const _NotificationTile({
    required this.item,
    required this.showFriendRequestActions,
    required this.isSubmitting,
    required this.isOpening,
    this.onTap,
  });

  bool get _isFriendRequestNotification =>
      item.type.toUpperCase() == 'FRIEND_REQUEST';

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return _buildTile(context, colors);
  }

  String _resolveNotificationText(BuildContext context) {
    final type = item.type.toUpperCase();
    final l10n = context.l10n;

    if (type.contains('LIKE')) {
      return l10n.notificationLiked;
    }
    if (type.contains('COMMENT')) {
      return l10n.notificationCommented;
    }
    if (type.contains('FOLLOW')) {
      return l10n.notificationFollowed;
    }
    if (type.contains('FRIEND_REQUEST')) {
      return l10n.friendRequestReceived;
    }

    return item.body;
  }

  Widget _buildTile(BuildContext context, AppColors colors) {

    return Material(
      color: item.isRead ? colors.sheetSurface : colors.inputFill,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: onTap,
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: colors.avatarPlaceholder,
              backgroundImage: item.actorAvatarUrl.isNotEmpty
                  ? NetworkImage(item.actorAvatarUrl)
                  : null,
              child: item.actorAvatarUrl.isEmpty
                  ? (item.actorName.trim().isNotEmpty
                        ? Text(
                            item.actorName
                                .trim()
                                .characters
                                .first
                                .toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colors.accent,
                            ),
                          )
                        : Icon(Icons.person, color: colors.textSecondary))
                  : null,
            ),
            title: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '${item.actorName} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: _resolveNotificationText(context)),
                ],
              ),
            ),
            subtitle: _buildSubtitle(context, colors),
            trailing: _buildTrailing(context, colors),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          if (_isFriendRequestNotification && showFriendRequestActions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSubmitting || item.entityId == null || item.entityId!.isEmpty
                        ? null
                        : () {
                            final entityId = item.entityId!.trim();
                            if (entityId.isEmpty) return;
                            
                            context.read<NotificationBloc>().add(
                              NotificationRejectFriendRequestRequested(
                                entityId,
                                item.id,
                              ),
                            );
                          },
                    child: Text(context.l10n.rejectFriendRequest),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: isSubmitting || item.entityId == null || item.entityId!.isEmpty
                        ? null
                        : () {
                            final entityId = item.entityId!.trim();
                            if (entityId.isEmpty) return;
                            
                            context.read<NotificationBloc>().add(
                              NotificationAcceptFriendRequestRequested(
                                entityId,
                                item.id,
                              ),
                            );
                          },
                    child: Text(context.l10n.acceptFriendRequest),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context, AppColors colors) {
    final createdAt = item.createdAt;
    if (createdAt == null) return null;

    final timeText = DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toLocal());
    
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        timeText,
        style: TextStyle(
          fontSize: 12,
          color: item.isRead ? colors.textSecondary : colors.accent,
          fontWeight: item.isRead ? FontWeight.normal : FontWeight.w600,
        ),
      ),
    );
  }

  Widget? _buildTrailing(BuildContext context, AppColors colors) {
    if (isOpening) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (item.isRead) {
      return null;
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: colors.accent,
        shape: BoxShape.circle,
      ),
    );
  }
}
