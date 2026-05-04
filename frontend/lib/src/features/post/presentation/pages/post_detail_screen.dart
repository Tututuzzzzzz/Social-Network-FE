import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/src/configs/injector/injector_conf.dart';
import 'package:frontend/src/core/cache/secure_local_storage.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/utils/failure_converter.dart';
import 'package:frontend/src/features/friend/data/repositories/friend_repository_impl.dart';
import 'package:frontend/src/features/friend/domain/usecases/send_friend_request.dart';
import 'package:frontend/src/features/post/domain/entities/post_entity.dart';
import 'package:frontend/src/features/post/domain/entities/post_media_entity.dart';
import 'package:frontend/src/features/post/domain/entities/post_media_upload_file.dart';
import 'package:frontend/src/features/post/domain/usecases/delete_post_usecase.dart';
import 'package:frontend/src/features/post/domain/usecases/update_post_usecase.dart';
import 'package:frontend/src/features/post/domain/usecases/upload_post_media_usecase.dart';
import 'package:frontend/src/features/post/domain/usecases/usecase_params.dart';
import 'package:frontend/src/features/post/presentation/bloc/post/post_bloc.dart';
import 'package:frontend/src/features/post/presentation/widgets/comments_sheet.dart';
import 'package:frontend/src/features/post/presentation/widgets/edit_post_bottom_sheet.dart';
import 'package:frontend/src/features/post/presentation/widgets/post_detail_content.dart';
import 'package:frontend/src/features/post/presentation/widgets/post_detail_image_actions_sheet.dart';
import 'package:frontend/src/features/post/presentation/widgets/post_detail_media_carousel.dart';
import 'package:frontend/src/features/post/presentation/widgets/post_owner_actions_sheet.dart';

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
      ).showSnackBar(const SnackBar(content: Text('Friend request sent')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send friend request')),
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
        onCommentsCountChanged: (count) {
          if (!mounted) return;
          setState(() {
            _commentCount = count;
          });
        },
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes to update.')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapFailureToMessage(failure))),
        );
      },
      (_) {
        setState(() {
          _post = _post.copyWith(
            content: hasContentChanged ? draft.content : _post.content,
            media: hasMediaChanged ? nextMedia : _post.media,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated.')),
        );
      },
    );
  }

  Future<List<PostMediaEntity>?> _uploadNewImages(
    List<XFile> newImages,
  ) async {
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

    return result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapFailureToMessage(failure))),
        );
        return null;
      },
      (media) => media,
    );
  }

  Future<void> _confirmDeletePost() async {
    if (_isDeletingPost || _isUpdatingPost) return;

    final l10n = context.l10n;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete post?'),
          content: const Text('This action cannot be undone.'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapFailureToMessage(failure))),
        );
      },
      (_) {
        Navigator.of(context).pop(true);
      },
    );
  }

  void _showFeatureSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Feature in development')));
  }

  String _formatFallbackUsername(String authorId) {
    if (authorId.isEmpty) return 'user';
    final raw = authorId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    if (raw.isEmpty) return 'user';
    return raw.length > 12 ? raw.substring(0, 12) : raw;
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;
    final imageUrls = _resolveImageUrls();
    final authorUsername = (post.authorUsername ?? '').trim().isNotEmpty
        ? post.authorUsername!.trim()
        : _formatFallbackUsername(post.authorId);
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
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.black),
              onPressed: _isOwner ? _openOwnerActionsSheet : _openImageActionsSheet,
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            PostDetailMediaCarousel(imageUrls: imageUrls),
            PostDetailContent(
              authorUsername: authorUsername,
              authorId: post.authorId,
              currentUserId: _currentUserId,
              isFollowing: _isFollowing,
              sendingFollowRequest: _sendingFollowRequest,
              isLiked: _isLiked,
              likesCount: likesCount,
              commentCount: commentCount,
              content: post.content,
              createdAt: post.createdAt,
              onFollowTap: _onFollowTap,
              onLikeTap: _toggleLike,
              onCommentsTap: _openCommentsSheet,
            ),
          ],
        ),
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
