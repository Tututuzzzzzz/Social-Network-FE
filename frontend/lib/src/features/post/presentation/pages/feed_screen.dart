import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../configs/injector/injector_conf.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/theme/app_colors.dart';
import 'package:frontend/src/core/realtime/realtime_socket_service.dart';
import 'package:frontend/src/features/chat/domain/usecases/fetch_chat_items_usecase.dart';
import 'package:frontend/src/features/chat/domain/usecases/usecase_params.dart';
import '../../../../core/cache/secure_local_storage.dart';
import '../../../../core/utils/failure_converter.dart';
import '../../../friend/data/repositories/friend_repository_impl.dart';
import '../../../friend/domain/usecases/send_friend_request.dart';
import '../../../../routes/app_route_path.dart';
import '../../domain/entities/post_comments_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/report_post_usecase.dart';
import '../../domain/usecases/usecase_params.dart';
import '../bloc/post/post_bloc.dart';
import '../widgets/feed_widgets.dart';
import '../widgets/feed_screen/post_options_sheet.dart';
import 'post_detail_screen.dart';
import 'package:frontend/src/core/testing/test_keys.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  List<PostEntity> _posts = const [];
  final Map<String, int> _commentCountOverrides = <String, int>{};
  String _currentUserId = '';
  bool _hasUnreadMessages = false;
  StreamSubscription<Map<String, dynamic>>? _messageNewSubscription;
  final Set<String> _friendIds = <String>{};
  final Set<String> _sendingFriendRequestAuthorIds = <String>{};
  final Set<String> _sentFriendRequestAuthorIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bootstrapFeed();
    });
    _bindMessageBadgeListener();
  }

  void _bindMessageBadgeListener() {
    final socket = getIt<RealtimeSocketService>();
    _messageNewSubscription = socket.notificationNewStream.listen((payload) {
      if (!mounted) return;

      final notificationRaw = payload['notification'];
      final notification = notificationRaw is Map
          ? Map<String, dynamic>.from(notificationRaw)
          : payload;

      final type = notification['type']?.toString().toUpperCase() ?? '';
      if (type != 'MESSAGE_NEW') {
        return;
      }

      if (!_hasUnreadMessages) {
        setState(() {
          _hasUnreadMessages = true;
        });
      }
    });
  }

  Future<void> _bootstrapFeed() async {
    await _resolveCurrentUserId();
    await _resolveFriendIds();
    await _syncUnreadChatBadge();
    if (!mounted) return;

    final postState = context.read<PostBloc>().state;
    if (postState is PostInitialState || postState is PostFailureState) {
      context.read<PostBloc>().add(PostLoadEvent());
    }
  }

  Future<void> _resolveCurrentUserId() async {
    if (_currentUserId.trim().isNotEmpty) return;

    final secureStorage = getIt<SecureLocalStorage>();
    final storedUserId = await secureStorage.load(key: 'user_id');
    final normalized = storedUserId.trim();
    if (normalized.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _currentUserId = normalized;
      });
    }
  }

  Future<void> _resolveFriendIds() async {
    if (_friendIds.isNotEmpty || _currentUserId.trim().isEmpty) {
      return;
    }

    try {
      final repository = getIt<FriendRepositoryImpl>();
      final friendIds = await repository.getAllFriendIds();
      if (!mounted) return;
      setState(() {
        _friendIds
          ..clear()
          ..addAll(friendIds);
      });
    } catch (_) {
      // Keep feed usable even if the friend list fails to load.
    }
  }

  Future<void> _syncUnreadChatBadge() async {
    try {
      final useCase = getIt<FetchChatItemsUseCase>();
      final result = await useCase(const ChatQueryParams(page: 1));
      result.fold(
        (_) {
          // Ignore unread badge sync errors to keep feed responsive.
        },
        (items) {
          final hasUnread = items.any((item) => item.unreadCount > 0);
          if (!mounted) return;
          setState(() {
            _hasUnreadMessages = hasUnread;
          });
        },
      );
    } catch (_) {
      // Keep badge state as-is if chat fetch fails.
    }
  }

  Future<void> _openCommentsSheet(PostEntity initialPost) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(
        initialPost: initialPost,
        currentUserId: _currentUserId.isEmpty ? null : _currentUserId,
        onCommentsChanged: (comments) =>
            _syncPostComments(initialPost.id, comments),
      ),
    );
  }

  void _syncPostComments(String postId, PostCommentsEntity comments) {
    if (!mounted) return;

    setState(() {
      _commentCountOverrides[postId] = comments.commentsCount;
      _posts = _posts.map((post) {
        if (post.id != postId) return post;
        return post.copyWith(
          comments: comments.comments,
          commentsCount: comments.commentsCount,
        );
      }).toList();
    });

    context.read<PostBloc>().add(
      PostCommentsChangedEvent(
        postId: postId,
        comments: comments.comments,
        commentsCount: comments.commentsCount,
      ),
    );
  }

  void _openSearchScreen() {
    context.go(AppRoutes.homeSearch.path);
  }

  void _openChatScreen() {
    if (_hasUnreadMessages) {
      setState(() {
        _hasUnreadMessages = false;
      });
    }
    context.go(AppRoutes.chat.path);
  }

  void _openAuthorProfile(PostEntity post) {
    final authorId = post.authorId.trim();
    if (authorId.isEmpty) {
      return;
    }

    context.pushNamed(
      AppRoutes.otherProfile.name,
      pathParameters: {'userId': authorId},
    );
  }

  void _showFeatureSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.featureInDevelopment)));
  }

  Future<void> _showPostOptionsSheet(PostEntity post) async {
    final l10n = context.l10n;
    final selectedAction = await showPostOptionsSheet(context, post);
    if (!mounted || selectedAction == null) return;

    switch (selectedAction) {
      case PostOptionAction.addToFavorites:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.postOptionAddToFavoritesDone)),
        );
        break;
      case PostOptionAction.aboutAccount:
        _showFeatureSoon();
        break;
      case PostOptionAction.hidePost:
        context.read<PostBloc>().add(
          PostDeleteEvent(DeletePostParams(postId: post.id)),
        );
        break;
      case PostOptionAction.report:
        final reason = await showReportReasonSheet(context);
        if (!mounted || reason == null) return;
        final reasonLabel = reportReasonLabel(reason, l10n);
        final result = await getIt<ReportPostUseCase>().call(
          ReportPostParams(
            postId: post.id,
            reason: reportReasonValue(reason),
            description: reasonLabel,
          ),
        );
        if (!mounted) return;
        result.match(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(mapFailureToMessage(failure))),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n.postOptionReportDoneWithReason(reasonLabel),
                ),
              ),
            );
          },
        );
        break;
    }
  }

  Future<void> _refreshPosts() async {
    context.read<PostBloc>().add(PostLoadEvent());
  }

  Future<void> _onFollowTap(PostEntity post) async {
    final authorId = post.authorId.trim();

    if (authorId.isEmpty) {
      return;
    }

    if (_sendingFriendRequestAuthorIds.contains(authorId) ||
        _sentFriendRequestAuthorIds.contains(authorId)) {
      return;
    }

    setState(() {
      _sendingFriendRequestAuthorIds.add(authorId);
    });

    try {
      final useCase = getIt<SendFriendRequest>();
      await useCase(authorId);

      if (!mounted) return;

      setState(() {
        _sentFriendRequestAuthorIds.add(authorId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Friend request sent successfully")),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send friend request. Please try again."),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sendingFriendRequestAuthorIds.remove(authorId);
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageNewSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<PostBloc, PostState>(
      listener: (context, state) {
        if (state is PostLoadedState) {
          _posts = state.posts;
          _commentCountOverrides.removeWhere((postId, _) {
            return state.posts.any((post) => post.id == postId);
          });
        }

        if (state is PostFailureState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }

        if (state is PostActionFailureState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final colors = AppColors.of(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final headerColors = isDark ? AppColors.light : colors;
        final visiblePosts = state is PostLoadedState ? state.posts : _posts;
        final sortedPosts = List<PostEntity>.of(visiblePosts)
          ..sort((a, b) {
            final byTime = b.createdAt.compareTo(a.createdAt);
            if (byTime != 0) return byTime;
            return b.id.compareTo(a.id);
          });
        final isLoadingInitial =
            state is PostLoadingState && sortedPosts.isEmpty;

        return Scaffold(
          backgroundColor: colors.scaffold,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            systemOverlayStyle:
                isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            backgroundColor: headerColors.appBar,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: headerColors.appBar,
            toolbarHeight: 72,
            leadingWidth: 168,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/logo.jpg',
                  height: 50,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      'Mochi',
                      style: TextStyle(
                        color: headerColors.textPrimary,
                        fontSize: 32,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    );
                  },
                ),
              ),
            ),
            actions: [
              IconButton(
                key: TestKeys.feedSearchButton,
                onPressed: _openSearchScreen,
                icon: Icon(
                  Icons.search_rounded,
                  color: headerColors.textPrimary,
                  size: 29,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      key: TestKeys.feedChatButton,
                      onPressed: _openChatScreen,
                      icon: Icon(
                        Icons.wechat_outlined,
                        color: headerColors.textPrimary,
                        size: 26,
                      ),
                    ),
                    if (_hasUnreadMessages)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: headerColors.badge,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: headerColors.badgeBorder,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          body: MediaQuery.removeViewInsets(
            context: context,
            removeBottom: true,
              child: isLoadingInitial
                  ? const FeedSkeletonList(itemCount: 2)
                  : sortedPosts.isEmpty
                  ? Center(
                      child: Text(
                        l10n.postOptionAllHiddenDescription,
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshPosts,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 6, bottom: 4),
                        itemCount: sortedPosts.length,
                        itemBuilder: (context, index) {
                          final post = sortedPosts[index];
                          final isSelfPost =
                              _currentUserId.isNotEmpty &&
                              post.authorId == _currentUserId;
                          final isAlreadyFriend = _friendIds.contains(
                            post.authorId,
                          );
                          final isSendingRequest =
                              _sendingFriendRequestAuthorIds.contains(
                                post.authorId,
                              );
                          final commentCountOverride =
                              _commentCountOverrides[post.id];
                          final displayPost = commentCountOverride == null
                              ? post
                              : post.copyWith(
                                  commentsCount: commentCountOverride,
                                );

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              final postBloc = context.read<PostBloc>();
                              final deleted =
                                  await Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: postBloc,
                                        child: PostDetailScreen(
                                          initialPost: displayPost,
                                          currentUserId: _currentUserId.isEmpty
                                              ? null
                                              : _currentUserId,
                                        ),
                                      ),
                                    ),
                                  );
                              if (!mounted || deleted != true) return;
                              postBloc.add(PostLocalPostDeletedEvent(post.id));
                            },
                            child: PostCard(
                              post: displayPost,
                              isLikedByMe:
                                  _currentUserId.isNotEmpty &&
                                  post.likes.contains(_currentUserId),
                              commentCountOverride:
                                  _commentCountOverrides[post.id],
                              isFollowing: isAlreadyFriend,
                              showFollowButton: !isSelfPost && isAlreadyFriend,
                              onLike: () {
                                context.read<PostBloc>().add(
                                  PostLikeToggleEvent(post.id),
                                );
                              },
                              onFollowTap: isSelfPost || isAlreadyFriend
                                  ? null
                                  : isSendingRequest
                                      ? null
                                      : () => _onFollowTap(post),
                              onAuthorTap: () => _openAuthorProfile(post),
                              onComment: () => _openCommentsSheet(post),
                              onViewComments: () => _openCommentsSheet(post),
                              onShare: _showFeatureSoon,
                              onSave: _showFeatureSoon,
                              onMore: () => _showPostOptionsSheet(post),
                              followingLabel: l10n.friendsLabel,
                              followLabel: '',
                            ),
                          );
                      },
                    ),
                  ),
          ),
        );
      },
    );
  }
}
