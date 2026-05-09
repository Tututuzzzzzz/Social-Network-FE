import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/failure_converter.dart';
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

  bool _isPostNotification(NotificationEntity item) => !_isFriendRequest(item);

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

  void _markAsReadIfNeeded(NotificationEntity item) {
    if (item.isRead) return;
    context.read<NotificationBloc>().add(
      NotificationMarkAsReadRequested(item.id),
    );
  }

  void _openActorProfile(NotificationEntity item) {
    if (item.actorId.isEmpty) return;
    context.pushNamed(
      AppRoutes.profile.name,
      pathParameters: {'userId': item.actorId},
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

  Future<void> _openPostNotification(NotificationEntity item) async {
    if (_openingPostNotificationId != null) return;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapFailureToMessage(failure))),
        );
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
        final postNotifications = state.items
            .where(_isPostNotification)
            .toList();
        final friendRequestNotifications = state.items
            .where(_isFriendRequest)
            .toList();

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: const Color(0xFFF3F3F3),
            appBar: AppBar(
              backgroundColor: const Color(0xFF2FC48F),
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                l10n.notificationsTitle,
                style: const TextStyle(
                  color: Colors.white,
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
                  color: Colors.white,
                  child: const TabBar(
                    indicatorColor: Color(0xFF36C38C),
                    labelColor: Color(0xFF36C38C),
                    unselectedLabelColor: Colors.black54,
                    tabs: [
                      Tab(text: 'Bài viết'),
                      Tab(text: 'Kết bạn'),
                    ],
                  ),
                ),
              ),
            ),
            body: state.isLoading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _NotificationListView(
                        items: postNotifications,
                        hasMore: state.hasMore,
                        emptyMessage: 'Chưa có thông báo bài viết nào',
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
                        emptyMessage: 'Chưa có lời mời kết bạn nào',
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
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            )
          : ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, thickness: 0.6),
              itemBuilder: (context, index) {
                if (index >= widget.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
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
  final VoidCallback onTap;

  const _NotificationTile({
    required this.item,
    required this.showFriendRequestActions,
    required this.isSubmitting,
    required this.isOpening,
    required this.onTap,
  });

  bool get _isFriendRequestNotification =>
      item.type.toUpperCase() == 'FRIEND_REQUEST';

  @override
  Widget build(BuildContext context) {
    final createdAt = item.createdAt;
    final timeText = createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toLocal())
        : '';

    return Material(
      color: item.isRead ? Colors.white : const Color(0xFFF0F7FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: onTap,
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade200,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          )
                        : const Icon(Icons.person, color: Colors.grey))
                  : null,
            ),
            title: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '${item.actorName} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: _isFriendRequestNotification
                        ? context.l10n.friendRequestReceived
                        : item.body,
                  ),
                ],
              ),
            ),
            subtitle: timeText.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      timeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: item.isRead ? Colors.grey : Colors.blueAccent,
                        fontWeight: item.isRead
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                    ),
                  )
                : null,
            trailing: isOpening
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : item.isRead
                ? null
                : Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
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
                    onPressed: isSubmitting
                        ? null
                        : () {
                            context.read<NotificationBloc>().add(
                              NotificationRejectFriendRequestRequested(
                                item.entityId!,
                                item.id,
                              ),
                            );
                          },
                    child: Text(context.l10n.rejectFriendRequest),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            context.read<NotificationBloc>().add(
                              NotificationAcceptFriendRequestRequested(
                                item.entityId!,
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
}
