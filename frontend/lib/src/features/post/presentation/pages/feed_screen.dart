import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/cache/secure_local_storage.dart';
import '../../../friend/domain/usecases/send_friend_request.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_state.dart';
import '../../../../routes/app_route_path.dart';
import '../../../../widgets/app_shell_bottom_nav_bar.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/usecase_params.dart';
import '../bloc/post/post_bloc.dart';
import '../widgets/feed_story_item.dart';
import '../widgets/feed_widgets.dart';
import '../widgets/post_options_sheet.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  List<PostEntity> _posts = const [];
  int _currentNavIndex = 0;
  String _currentUserId = '';
  final Set<String> _sendingFriendRequestAuthorIds = <String>{};
  final Set<String> _sentFriendRequestAuthorIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bootstrapFeed();
    });
  }

  Future<void> _bootstrapFeed() async {
    await _resolveCurrentUserId();
    if (!mounted) return;
    context.read<PostBloc>().add(PostLoadEvent());
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

  Future<void> _openCommentsSheet(PostEntity initialPost) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          CommentsSheet(
            initialPost: initialPost,
            currentUserId: _currentUserId.isEmpty ? null : _currentUserId,
          ),
    );
  }

  Future<void> _openCreatePostScreen() async {
    final postBloc = context.read<PostBloc>();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: postBloc,
          child: const CreatePostScreen(),
        ),
      ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.postOptionReportDoneWithReason(
                reportReasonLabel(reason, l10n),
              ),
            ),
          ),
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Friend request sent successfully")));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send friend request. Please try again.")),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _sendingFriendRequestAuthorIds.remove(authorId);
      });
    }
  }

  void _onBottomNavTap(int index) {
    if (index == _currentNavIndex) return;

    setState(() => _currentNavIndex = index);

    switch (index) {
      case 0:
        context.go(AppRoutes.home.path);
        break;
      case 1:
        context.go(AppRoutes.reels.path);
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<PostBloc, PostState>(
      listener: (context, state) {
        if (state is PostLoadedState) {
          _posts = state.posts;
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
        final visiblePosts = state is PostLoadedState ? state.posts : _posts;
        final isLoadingInitial =
            state is PostLoadingState && visiblePosts.isEmpty;

        return Scaffold(
          backgroundColor: const Color(0xFFF3F3F3),
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.white,
            leading: IconButton(
              icon: const Icon(
                Icons.add_box_outlined,
                color: Colors.black,
                size: 22,
              ),
              onPressed: _openCreatePostScreen,
            ),
            title: Image.asset(
              'assets/images/logo.jpg',
              height: 34,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Mochi',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: Colors.black,
                    ),
                  ],
                );
              },
            ),
            centerTitle: true,
            actions: [
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, notificationState) {
                  final hasUnreadNotifications = notificationState.unreadCount > 0;
                  
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () => context.push(AppRoutes.notifications.path),
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Colors.black,
                          size: 22,
                        ),
                      ),
                      if (hasUnreadNotifications)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.8),
              child: Container(height: 0.8, color: Colors.grey.shade200),
            ),
          ),
          body: MediaQuery.removeViewInsets(
            context: context,
            removeBottom: true,
            child: isLoadingInitial
                ? const FeedSkeletonList(itemCount: 2)
                : visiblePosts.isEmpty
                ? Center(
                    child: Text(
                      l10n.postOptionAllHiddenDescription,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshPosts,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 6, bottom: 4),
                      itemCount: 1 + visiblePosts.length,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildStoriesStrip(visiblePosts);
                        }

                        final post = visiblePosts[index - 1];
                        final hasSentRequest = _sentFriendRequestAuthorIds
                            .contains(post.authorId);
                        final isSendingRequest = _sendingFriendRequestAuthorIds
                            .contains(post.authorId);

                        return PostCard(
                          post: post,
                          isLikedByMe: _currentUserId.isNotEmpty &&
                              post.likes.contains(_currentUserId),
                          isFollowing: hasSentRequest,
                          onLike: () {
                            context.read<PostBloc>().add(
                              PostLikeToggleEvent(post.id),
                            );
                          },
                          onFollowTap: isSendingRequest
                              ? null
                              : () => _onFollowTap(post),
                          onAuthorTap: _showFeatureSoon,
                          onComment: () => _openCommentsSheet(post),
                          onViewComments: () => _openCommentsSheet(post),
                          onShare: _showFeatureSoon,
                          onSave: _showFeatureSoon,
                          onMore: () => _showPostOptionsSheet(post),
                          followingLabel: hasSentRequest
                              ? "Following"
                              : "Follow",
                        );
                      },
                    ),
                  ),
          ),
          bottomNavigationBar: AppShellBottomNavBar(
            selectedIndex: _currentNavIndex,
            onTap: _onBottomNavTap,
          ),
        );
      },
    );
  }

  Widget _buildStoriesStrip(List<PostEntity> posts) {
    final stories = _buildStoriesData(posts);

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 7),
          child: SizedBox(
            height: 94,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: stories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) =>
                  FeedStoryItem(story: stories[index]),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  List<FeedStoryData> _buildStoriesData(List<PostEntity> posts) {
    final stories = <FeedStoryData>[
      const FeedStoryData(
        label: '',
        avatarUrl: 'assets/images/logo1.jpg',
        isAsset: true,
        showPlusBadge: true,
      ),
    ];

    final usedIds = <String>{};
    for (final post in posts) {
      if (usedIds.contains(post.authorId)) continue;
      usedIds.add(post.authorId);

      final username = (post.authorUsername ?? '').trim();
      final displayLabel = username.isNotEmpty
          ? username
          : post.authorId.substring(
              0,
              post.authorId.length > 8 ? 8 : post.authorId.length,
            );

      stories.add(
        FeedStoryData(
          label: displayLabel,
          avatarUrl: (post.authorAvatarUrl ?? '').trim(),
        ),
      );

      if (stories.length >= 8) break;
    }

    return stories;
  }
}
