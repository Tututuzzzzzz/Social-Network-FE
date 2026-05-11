import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:frontend/src/configs/injector/injector_conf.dart';
import 'package:frontend/src/core/cache/secure_local_storage.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/theme/app_colors.dart';
import 'package:frontend/src/core/utils/failure_converter.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import 'package:frontend/src/features/friend/data/repositories/friend_repository_impl.dart';
import 'package:frontend/src/features/friend/domain/usecases/send_friend_request.dart';
import 'package:frontend/src/features/post/domain/entities/post_entity.dart';
import 'package:frontend/src/features/post/domain/entities/post_comments_entity.dart';
import 'package:frontend/src/features/post/domain/entities/post_media_entity.dart';
import 'package:frontend/src/features/post/domain/entities/post_media_upload_file.dart';
import 'package:frontend/src/features/post/domain/usecases/delete_post_usecase.dart';
import 'package:frontend/src/features/post/domain/usecases/update_post_usecase.dart';
import 'package:frontend/src/features/post/domain/usecases/upload_post_media_usecase.dart';
import 'package:frontend/src/features/post/domain/usecases/usecase_params.dart';
import 'package:frontend/src/features/post/presentation/bloc/post/post_bloc.dart';
import 'package:frontend/src/features/post/presentation/widgets/comments_sheet.dart';
import 'package:frontend/src/features/post/presentation/widgets/post_detail_screen/edit_post_bottom_sheet.dart';
import 'package:frontend/src/features/post/presentation/widgets/post_detail_screen/post_detail_image_actions_sheet.dart';
import 'package:frontend/src/features/post/presentation/widgets/post_detail_screen/post_owner_actions_sheet.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({
    super.key,
    required this.initialPost,
    this.currentUserId,
  });

  final PostEntity initialPost;
  final String? currentUserId;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late PostEntity _post;
  String _currentUserId = '';
  bool _isFollowing = false;
  bool _sendingFollowRequest = false;
  bool _isLiked = false;
  int _likesCount = 0;
  int _commentCount = 0;
  bool _isUpdatingPost = false;
  bool _isDeletingPost = false;

  bool get _isOwner =>
      _currentUserId.isNotEmpty && _currentUserId == _post.authorId;

  @override
  void initState() {
    super.initState();
    _post = widget.initialPost;
    final providedUserId = (widget.currentUserId ?? '').trim();
    if (providedUserId.isNotEmpty) {
      _currentUserId = providedUserId;
    }
    _likesCount = _post.likes.length;
    _commentCount = _post.commentsCount;
    if (_currentUserId.isNotEmpty) {
      _isLiked = _post.likes.contains(_currentUserId);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    await _resolveCurrentUserId();
    _syncLikeState();
    await _resolveFriendStatus();
  }

  void _syncLikeState() {
    if (_currentUserId.isEmpty) return;
    final isLiked = _post.likes.contains(_currentUserId);
    if (_isLiked == isLiked) return;
    setState(() {
      _isLiked = isLiked;
    });
  }

  Future<void> _resolveCurrentUserId() async {
    if (widget.currentUserId != null &&
        widget.currentUserId!.trim().isNotEmpty) {
      final provided = widget.currentUserId!.trim();
      if (provided != _currentUserId && mounted) {
        setState(() => _currentUserId = provided);
      } else {
        _currentUserId = provided;
      }
      return;
    }

    final secureStorage = getIt<SecureLocalStorage>();
    final stored = await secureStorage.load(key: 'user_id');
    final normalized = stored.trim();
    if (normalized.isNotEmpty) {
      if (!mounted) return;
      setState(() => _currentUserId = normalized);
    }
  }

  Future<void> _resolveFriendStatus() async {
    try {
      final repo = getIt<FriendRepositoryImpl>();
      final ids = await repo.getAllFriendIds();
      final authorId = _post.authorId.trim();
      if (!mounted) return;
      setState(() {
        _isFollowing = authorId.isNotEmpty && ids.contains(authorId);
      });
    } catch (_) {
      // ignore errors, keep default false
    }
  }

  Future<void> _onFollowTap() async {
    final authorId = _post.authorId.trim();
    if (authorId.isEmpty) return;
    if (_sendingFollowRequest || _isFollowing) return;

    setState(() => _sendingFollowRequest = true);
    try {
      final useCase = getIt<SendFriendRequest>();
      await useCase(authorId);
      if (!mounted) return;
      setState(() => _isFollowing = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.friendRequestSendSuccess)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.friendRequestSendError)),
      );
    } finally {
      if (mounted) {
        setState(() => _sendingFollowRequest = false);
      }
    }
  }

  void _toggleLike() {
    if (_currentUserId.isEmpty) {
      _showFeatureSoon();
      return;
    }

    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
      if (_likesCount < 0) _likesCount = 0;
    });

    try {
      context.read<PostBloc>().add(PostLikeToggleEvent(_post.id));
    } catch (_) {}
  }

  Future<void> _openCommentsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(
        initialPost: _post,
        currentUserId: _currentUserId.isEmpty ? null : _currentUserId,
        onCommentsChanged: _syncPostComments,
        onAuthorProfileTap: _openProfileFromComments,
      ),
    );
  }

  void _syncPostComments(PostCommentsEntity comments) {
    if (!mounted) return;

    final updatedPost = _post.copyWith(
      comments: comments.comments,
      commentsCount: comments.commentsCount,
    );

    setState(() {
      _post = updatedPost;
      _commentCount = comments.commentsCount;
    });

    context.read<PostBloc>().add(
      PostCommentsChangedEvent(
        postId: _post.id,
        comments: comments.comments,
        commentsCount: comments.commentsCount,
      ),
    );
  }

  Future<void> _openImageActionsSheet() {
    return showPostDetailImageActionsSheet(
      context,
      onSaveImage: _showFeatureSoon,
      onCopyImage: _showFeatureSoon,
      onShareImage: _showFeatureSoon,
    );
  }

  Future<void> _openOwnerActionsSheet() async {
    if (_isUpdatingPost || _isDeletingPost) return;
    final action = await showPostOwnerActionsSheet(context);
    if (!mounted || action == null) return;

    switch (action) {
      case PostOwnerAction.edit:
        await _openEditPost();
        break;
      case PostOwnerAction.delete:
        await _confirmDeletePost();
        break;
    }
  }

  Future<void> _openEditPost() async {
    if (_isUpdatingPost || _isDeletingPost) return;

    final draft = await showEditPostBottomSheet(context: context, post: _post);
    if (!mounted || draft == null) return;

    setState(() => _isUpdatingPost = true);

    final uploadedMedia = await _uploadNewImages(draft.newImages);
    if (!mounted) return;

    if (uploadedMedia == null) {
      setState(() => _isUpdatingPost = false);
      return;
    }

    final nextMedia = <PostMediaEntity>[
      ...draft.retainedMedia,
      ...uploadedMedia,
    ];

    final hasContentChanged =
        draft.content.trim() != (_post.content ?? '').trim();
    final hasMediaChanged = !listEquals(nextMedia, _post.media);

    if (!hasContentChanged && !hasMediaChanged) {
      setState(() => _isUpdatingPost = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.noChangesToUpdate)));
      return;
    }

    final useCase = getIt<UpdatePostUseCase>();
    final result = await useCase.call(
      UpdatePostParams(
        postId: _post.id,
        content: hasContentChanged ? draft.content : null,
        media: hasMediaChanged ? nextMedia : null,
        hasContentField: hasContentChanged,
        hasMediaField: hasMediaChanged,
      ),
    );

    if (!mounted) return;

    setState(() => _isUpdatingPost = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mapFailureToMessage(failure))));
      },
      (_) {
        final updatedPost = _post.copyWith(
          content: hasContentChanged ? draft.content : _post.content,
          media: hasMediaChanged ? nextMedia : _post.media,
        );
        setState(() {
          _post = updatedPost;
        });
        context.read<PostBloc>().add(PostLocalPostChangedEvent(updatedPost));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.postUpdated)));
      },
    );
  }

  Future<List<PostMediaEntity>?> _uploadNewImages(List<XFile> newImages) async {
    if (newImages.isEmpty) {
      return const [];
    }

    final files = <PostMediaUploadFile>[];

    for (final image in newImages) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        files.add(PostMediaUploadFile(name: image.name, bytes: bytes));
      } else {
        files.add(PostMediaUploadFile(name: image.name, path: image.path));
      }
    }

    final useCase = getIt<UploadPostMediaUseCase>();
    final result = await useCase.call(UploadPostMediaParams(files: files));

    if (!mounted) return null;

    return result.fold((failure) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mapFailureToMessage(failure))));
      return null;
    }, (media) => media);
  }

  Future<void> _confirmDeletePost() async {
    if (_isDeletingPost || _isUpdatingPost) return;

    final l10n = context.l10n;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deletePostTitle),
          content: Text(l10n.deletePostConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.deleteAction),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldDelete != true) return;

    setState(() => _isDeletingPost = true);

    final useCase = getIt<DeletePostUseCase>();
    final result = await useCase.call(DeletePostParams(postId: _post.id));

    if (!mounted) return;

    setState(() => _isDeletingPost = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mapFailureToMessage(failure))));
      },
      (_) {
        context.read<PostBloc>().add(PostLocalPostDeletedEvent(_post.id));
        Navigator.of(context).pop(true);
      },
    );
  }

  void _showFeatureSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.featureInDevelopment)));
  }

  void _openAuthorProfile() {
    final authorId = _post.authorId.trim();
    if (authorId.isEmpty) {
      return;
    }

    final router = GoRouter.of(context);
    Navigator.of(context, rootNavigator: true).pop();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.pushNamed(
        AppRoutes.otherProfile.name,
        pathParameters: {'userId': authorId},
      );
    });
  }

  void _openProfileFromComments(String authorId) {
    final normalizedAuthorId = authorId.trim();
    if (normalizedAuthorId.isEmpty) {
      return;
    }

    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    Navigator.of(context, rootNavigator: true).pop();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.pushNamed(
        AppRoutes.otherProfile.name,
        pathParameters: {'userId': normalizedAuthorId},
      );
    });
  }

  String _formatFallbackUsername(String authorId) {
    if (authorId.isEmpty) return 'user';
    final raw = authorId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    if (raw.isEmpty) return 'user';
    return raw.length > 12 ? raw.substring(0, 12) : raw;
  }

  String _resolveAuthorName(PostEntity post) {
    final displayName = post.authorDisplayName?.trim() ?? '';
    if (displayName.isNotEmpty) return displayName;

    final username = post.authorUsername?.trim() ?? '';
    if (username.isNotEmpty) return username;

    return _formatFallbackUsername(post.authorId);
  }

  String _formatPostTime(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return context.l10n.timeJustNow;
    if (diff.inMinutes < 60) return context.l10n.timeMinutesAgo(diff.inMinutes.toString());
    if (diff.inHours < 24) return context.l10n.timeHoursAgo(diff.inHours.toString());
    if (diff.inDays < 7) return context.l10n.timeDaysAgo(diff.inDays.toString());

    return DateFormat('dd/MM/yyyy').format(createdAt.toLocal());
  }

  Future<void> _openMoreActions() {
    return _isOwner ? _openOwnerActionsSheet() : _openImageActionsSheet();
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;
    final imageUrls = _resolveImageUrls();
    final authorName = _resolveAuthorName(post);
    final likesCount = _likesCount;
    final commentCount = _commentCount;
    return BlocListener<PostBloc, PostState>(
      listenWhen: (_, state) => state is PostLoadedState,
      listener: (context, state) {
        if (state is! PostLoadedState) return;
        final updated = state.posts.firstWhere(
          (item) => item.id == _post.id,
          orElse: () => _post,
        );
        final nextLikes = updated.likes.length;
        final nextComments = updated.commentsCount;
        final nextIsLiked =
            _currentUserId.isNotEmpty && updated.likes.contains(_currentUserId);
        final shouldUpdate =
            updated != _post ||
            nextLikes != _likesCount ||
            nextComments != _commentCount ||
            nextIsLiked != _isLiked;
        if (!shouldUpdate) return;
        setState(() {
          _post = updated;
          _likesCount = nextLikes;
          _commentCount = nextComments;
          _isLiked = nextIsLiked;
        });
      },
      child: imageUrls.length == 1
          ? _SingleImageFacebookDetail(
              post: post,
              imageUrl: imageUrls.first,
              authorName: authorName,
              timeText: _formatPostTime(post.createdAt),
              isLiked: _isLiked,
              likesCount: likesCount,
              commentCount: commentCount,
              onClose: () => Navigator.pop(context),
              onMore: () => _openMoreActions(),
              onLike: _toggleLike,
              onComment: () => _openCommentsSheet(),
              onShare: _showFeatureSoon,
              onAuthorTap: _openAuthorProfile,
            )
          : _ScrollableFacebookDetail(
              post: post,
              imageUrls: imageUrls,
              authorName: authorName,
              timeText: _formatPostTime(post.createdAt),
              currentUserId: _currentUserId,
              isFollowing: _isFollowing,
              sendingFollowRequest: _sendingFollowRequest,
              isLiked: _isLiked,
              likesCount: likesCount,
              commentCount: commentCount,
              onClose: () => Navigator.pop(context),
              onMore: () => _openMoreActions(),
              onFollowTap: () => _onFollowTap(),
              onLike: _toggleLike,
              onComment: () => _openCommentsSheet(),
              onShare: _showFeatureSoon,
              onAuthorTap: _openAuthorProfile,
            ),
    );
  }

  List<String> _resolveImageUrls() {
    final results = <String>[];
    for (final item in _post.media) {
      final url = item.mediaUrl?.trim();
      if (url != null && url.isNotEmpty) {
        results.add(url);
        continue;
      }
      final key = item.objectKey.trim();
      if (key.isNotEmpty &&
          (key.startsWith('http://') || key.startsWith('https://'))) {
        results.add(key);
      }
    }
    return results;
  }
}

class _SingleImageFacebookDetail extends StatelessWidget {
  const _SingleImageFacebookDetail({
    required this.post,
    required this.imageUrl,
    required this.authorName,
    required this.timeText,
    required this.isLiked,
    required this.likesCount,
    required this.commentCount,
    required this.onClose,
    required this.onMore,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onAuthorTap,
  });

  final PostEntity post;
  final String imageUrl;
  final String authorName;
  final String timeText;
  final bool isLiked;
  final int likesCount;
  final int commentCount;
  final VoidCallback onClose;
  final VoidCallback onMore;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.mediaBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              const SizedBox(height: 96),
              Expanded(
                child: Center(
                  child: _FacebookImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    backgroundColor: colors.mediaBackground,
                  ),
                ),
              ),
              _SingleImagePostInfo(
                post: post,
                authorName: authorName,
                timeText: timeText,
                isLiked: isLiked,
                likesCount: likesCount,
                commentCount: commentCount,
                onLike: onLike,
                onComment: onComment,
                onShare: onShare,
                onAuthorTap: onAuthorTap,
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _DarkTopControls(onClose: onClose, onMore: onMore),
          ),
        ],
      ),
    );
  }
}

class _ScrollableFacebookDetail extends StatelessWidget {
  const _ScrollableFacebookDetail({
    required this.post,
    required this.imageUrls,
    required this.authorName,
    required this.timeText,
    required this.currentUserId,
    required this.isFollowing,
    required this.sendingFollowRequest,
    required this.isLiked,
    required this.likesCount,
    required this.commentCount,
    required this.onClose,
    required this.onMore,
    required this.onFollowTap,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onAuthorTap,
  });

  final PostEntity post;
  final List<String> imageUrls;
  final String authorName;
  final String timeText;
  final String currentUserId;
  final bool isFollowing;
  final bool sendingFollowRequest;
  final bool isLiked;
  final int likesCount;
  final int commentCount;
  final VoidCallback onClose;
  final VoidCallback onMore;
  final VoidCallback onFollowTap;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final showFollow =
        currentUserId.isNotEmpty && currentUserId != post.authorId;
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.postDetailSurface,
      appBar: AppBar(
        backgroundColor: colors.postDetailSurface,
        foregroundColor: colors.postDetailText,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: colors.mediaBackground,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.postDetailText, size: 28),
          onPressed: onClose,
        ),
        title: Text(
          context.l10n.postAuthorTitle(authorName),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.postDetailText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: colors.postDetailText),
            onPressed: onMore,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: colors.postDetailSurface,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FacebookAuthorRow(
                  post: post,
                  authorName: authorName,
                  timeText: timeText,
                  showFollow: showFollow,
                  isFollowing: isFollowing,
                  sendingFollowRequest: sendingFollowRequest,
                  dark: true,
                  onFollowTap: onFollowTap,
                  onAuthorTap: onAuthorTap,
                ),
                if ((post.content ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    post.content!.trim(),
                    style: TextStyle(
                      color: colors.postDetailSubtleText,
                      fontSize: 16,
                      height: 1.28,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _FacebookActionBar(
                  isLiked: isLiked,
                  likesCount: likesCount,
                  commentCount: commentCount,
                  shareCount: 0,
                  dark: true,
                  onLike: onLike,
                  onComment: onComment,
                  onShare: onShare,
                ),
              ],
            ),
          ),
          for (final imageUrl in imageUrls) ...[
            Container(height: 8, color: colors.postDetailDivider),
            _FacebookImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              backgroundColor: colors.mediaBackground,
            ),
          ],
        ],
      ),
    );
  }
}

class _DarkTopControls extends StatelessWidget {
  const _DarkTopControls({required this.onClose, required this.onMore});

  final VoidCallback onClose;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 20),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.close, color: colors.postDetailText, size: 30),
              onPressed: onClose,
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                Icons.more_horiz,
                color: colors.postDetailText,
                size: 30,
              ),
              onPressed: onMore,
            ),
          ],
        ),
      ),
    );
  }
}

class _SingleImagePostInfo extends StatelessWidget {
  const _SingleImagePostInfo({
    required this.post,
    required this.authorName,
    required this.timeText,
    required this.isLiked,
    required this.likesCount,
    required this.commentCount,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onAuthorTap,
  });

  final PostEntity post;
  final String authorName;
  final String timeText;
  final bool isLiked;
  final int likesCount;
  final int commentCount;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.mediaBackground.withValues(alpha: 0.0),
              colors.mediaBackground.withValues(alpha: 0.84),
              colors.mediaBackground,
            ],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(14, 42, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _PostAuthorAvatar(
                  post: post,
                  authorName: authorName,
                  onTap: onAuthorTap,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onAuthorTap,
                    child: Text(
                      authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.postDetailText,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  timeText,
                  style: TextStyle(
                    color: colors.postDetailSubtleText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.public,
                  color: colors.postDetailSubtleText,
                  size: 13,
                ),
              ],
            ),
            if ((post.content ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                post.content!.trim(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.postDetailText,
                  fontSize: 15,
                  height: 1.28,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _FacebookActionBar(
              isLiked: isLiked,
              likesCount: likesCount,
              commentCount: commentCount,
              shareCount: 0,
              dark: true,
              onLike: onLike,
              onComment: onComment,
              onShare: onShare,
            ),
          ],
        ),
      ),
    );
  }
}

class _FacebookAuthorRow extends StatelessWidget {
  const _FacebookAuthorRow({
    required this.post,
    required this.authorName,
    required this.timeText,
    required this.showFollow,
    required this.isFollowing,
    required this.sendingFollowRequest,
    required this.dark,
    required this.onFollowTap,
    required this.onAuthorTap,
  });

  final PostEntity post;
  final String authorName;
  final String timeText;
  final bool showFollow;
  final bool isFollowing;
  final bool sendingFollowRequest;
  final bool dark;
  final VoidCallback onFollowTap;
  final VoidCallback onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final primary = dark ? colors.postDetailText : colors.textPrimary;
    final secondary =
        dark ? colors.postDetailSubtleText : colors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PostAuthorAvatar(
          post: post,
          authorName: authorName,
          onTap: onAuthorTap,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: onAuthorTap,
                      child: Text(
                        authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  if (showFollow) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: isFollowing || sendingFollowRequest
                          ? null
                          : onFollowTap,
                      child: Text(
                        isFollowing ? context.l10n.friendsLabel : "",
                        style: TextStyle(
                          color: AppColors.of(context).postDetailLink,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    timeText,
                    style: TextStyle(color: secondary, fontSize: 13),
                  ),
                  const SizedBox(width: 5),
                  Icon(Icons.public, color: secondary, size: 13),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PostAuthorAvatar extends StatelessWidget {
  const _PostAuthorAvatar({
    required this.post,
    required this.authorName,
    this.onTap,
  });

  final PostEntity post;
  final String authorName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final avatarUrl = post.authorAvatarUrl?.trim() ?? '';
    final fallback = authorName.trim().isEmpty
        ? '?'
        : authorName.trim().characters.first.toUpperCase();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CircleAvatar(
        radius: 22,
        backgroundColor: colors.avatarPlaceholder,
        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
        child: avatarUrl.isEmpty
            ? Text(
                fallback,
                style: TextStyle(
                  color: colors.postDetailText,
                  fontWeight: FontWeight.w800,
                ),
              )
            : null,
      ),
    );
  }
}

class _FacebookActionBar extends StatelessWidget {
  const _FacebookActionBar({
    required this.isLiked,
    required this.likesCount,
    required this.commentCount,
    required this.shareCount,
    required this.dark,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  final bool isLiked;
  final int likesCount;
  final int commentCount;
  final int shareCount;
  final bool dark;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = dark ? colors.postDetailSubtleText : colors.textPrimary;

    return Row(
      children: [
        _ActionMetric(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          text: _formatCount(likesCount),
          color: isLiked ? colors.likeActive : color,
          onTap: onLike,
        ),
        const SizedBox(width: 22),
        _ActionMetric(
          icon: Icons.chat_bubble_outline,
          text: _formatCount(commentCount),
          color: color,
          onTap: onComment,
        ),
        const SizedBox(width: 22),
        _ActionMetric(
          icon: Icons.reply_rounded,
          text: shareCount > 0 ? _formatCount(shareCount) : '',
          color: color,
          onTap: onShare,
        ),
      ],
    );
  }
}

class _ActionMetric extends StatelessWidget {
  const _ActionMetric({
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 25),
          if (text.isNotEmpty) ...[
            const SizedBox(width: 7),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FacebookImage extends StatelessWidget {
  const _FacebookImage({
    required this.imageUrl,
    required this.fit,
    required this.backgroundColor,
  });

  final String imageUrl;
  final BoxFit fit;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      constraints: const BoxConstraints(minHeight: 260),
      child: Image.network(
        imageUrl,
        fit: fit,
        alignment: Alignment.center,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            height: 320,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, __, ___) => SizedBox(
          height: 320,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: AppColors.of(context)
                  .postDetailSubtleText
                  .withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatCount(int value) {
  if (value >= 1000000) {
    final m = value / 1000000;
    return '${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
  }
  if (value >= 1000) {
    final k = value / 1000;
    return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}K';
  }
  return value.toString();
}
