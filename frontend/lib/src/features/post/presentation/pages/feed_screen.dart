import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/cache/secure_local_storage.dart';
import '../../../friend/data/repositories/friend_repository_impl.dart';
import '../../../friend/domain/usecases/send_friend_request.dart';
import '../../../../routes/app_route_path.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/usecase_params.dart';
import '../bloc/post/post_bloc.dart';
import '../widgets/feed_widgets.dart';
import '../widgets/post_options_sheet.dart';
import 'post_detail_screen.dart';

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
  }

  Future<void> _bootstrapFeed() async {
    await _resolveCurrentUserId();
    await _resolveFriendIds();
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
            onCommentsCountChanged: (count) {
              if (!mounted) return;
              setState(() {
                _commentCountOverrides[initialPost.id] = count;
              });
            },
          ),
    );
  }

  void _openSearchScreen() {
    context.go(AppRoutes.homeSearch.path);
  }

  void _openChatScreen() {
    context.go(AppRoutes.chat.path);
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
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: const Color(0xFF2FC48F),
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: const Color(0xFF2FC48F),
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
                    return const Text(
                      'Mochi',
                      style: TextStyle(
                        color: Colors.black,
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
                onPressed: _openSearchScreen,
                icon: const Icon(
                  Icons.search_rounded,
                  color: Colors.black,
                  size: 29,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  onPressed: _openChatScreen,
                  icon: const Icon(
                    Icons.wechat_outlined,
                    color: Colors.black,
                    size: 26,
                  ),
                ),
              ),
            ],
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
                      itemCount: visiblePosts.length,
                      itemBuilder: (context, index) {
                        final post = visiblePosts[index];
                        final isSelfPost =
                            _currentUserId.isNotEmpty &&
                            post.authorId == _currentUserId;
                        final isAlreadyFriend = _friendIds.contains(post.authorId);
                        final hasSentRequest = _sentFriendRequestAuthorIds
                            .contains(post.authorId);
                        final isSendingRequest = _sendingFriendRequestAuthorIds
                            .contains(post.authorId);

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            final postBloc = context.read<PostBloc>();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: postBloc,
                                  child: PostDetailScreen(
                                    initialPost: post,
                                    currentUserId:
                                        _currentUserId.isEmpty ? null : _currentUserId,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: PostCard(
                            post: post,
                          isLikedByMe: _currentUserId.isNotEmpty &&
                              post.likes.contains(_currentUserId),
                          commentCountOverride: _commentCountOverrides[post.id],
                          isFollowing: isAlreadyFriend,
                          showFollowButton: !isSelfPost,
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
                          onAuthorTap: _showFeatureSoon,
                          onComment: () => _openCommentsSheet(post),
                          onViewComments: () => _openCommentsSheet(post),
                          onShare: _showFeatureSoon,
                          onSave: _showFeatureSoon,
                          onMore: () => _showPostOptionsSheet(post),
                          followingLabel: isAlreadyFriend
                              ? "Bạn bè"
                              : hasSentRequest
                              ? "Following"
                              : "Follow",
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
