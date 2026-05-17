import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/src/configs/injector/injector_conf.dart';
import 'package:frontend/src/features/post/domain/entities/post_comment_entity.dart';
import 'package:frontend/src/features/post/domain/entities/post_comments_entity.dart';
import 'package:frontend/src/features/post/domain/entities/post_entity.dart';
import 'package:frontend/src/features/post/domain/usecases/create_comment_usecase.dart';
import 'package:frontend/src/features/post/domain/usecases/delete_comment_usecase.dart';
import 'package:frontend/src/features/post/domain/usecases/get_comments_usecase.dart';
import 'package:frontend/src/features/post/domain/usecases/update_comment_usecase.dart';
import 'package:intl/intl.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/theme/app_colors.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'comments_sheet/comment_actions.dart';
import 'comments_sheet/comment_avatar.dart';
import 'comments_sheet/comment_models.dart';

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({
    super.key,
    required this.initialPost,
    required this.currentUserId,
    this.onCommentsCountChanged,
    this.onCommentsChanged,
    this.onAuthorProfileTap,
    this.highlightedCommentId,
    this.initialReplyCommentId,
    this.autoFocusComposer = false,
  });

  final PostEntity initialPost;
  final String? currentUserId;
  final ValueChanged<int>? onCommentsCountChanged;
  final ValueChanged<PostCommentsEntity>? onCommentsChanged;
  final ValueChanged<String>? onAuthorProfileTap;
  final String? highlightedCommentId;
  final String? initialReplyCommentId;
  final bool autoFocusComposer;

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final Map<String, GlobalKey> _commentKeys = <String, GlobalKey>{};
  final Set<String> _commentActionInProgress = <String>{};
  PostCommentEntity? _replyTarget;
  late List<PostCommentEntity> _comments;
  bool _isLoadingComments = false;
  bool _isSubmitting = false;
  String? _activeHighlightCommentId;
  bool _didAutoHighlight = false;
  bool _didInitializeReplyTarget = false;
  int _commentsVersion = 0;
  late final bool _didDeferInitialComments;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _activeHighlightCommentId = widget.highlightedCommentId?.trim();
    _didDeferInitialComments = widget.initialPost.comments.any(
      (comment) => !_hasUsableAuthorMetadata(comment),
    );
    _comments = _didDeferInitialComments
        ? const []
        : List<PostCommentEntity>.from(widget.initialPost.comments);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );
    if ((_activeHighlightCommentId ?? '').isNotEmpty) {
      _pulseController.repeat(reverse: true);
    }

    _loadCommentsFromServer();
  }

  Future<void> _loadCommentsFromServer() async {
    if (_isLoadingComments) return;

    final requestVersion = _commentsVersion;
    setState(() => _isLoadingComments = true);

    try {
      final useCase = getIt<GetCommentsUseCase>();
      final result = await useCase.call(
        GetCommentsParams(postId: widget.initialPost.id),
      );

      result.fold(
        (_) {
          if (!mounted) return;
          if (_didDeferInitialComments && _comments.isEmpty) {
            setState(() {
              _comments = List<PostCommentEntity>.from(
                widget.initialPost.comments,
              );
            });
          }
        },
        (data) {
          if (!mounted) return;
          if (requestVersion != _commentsVersion) return;
          setState(() {
            _comments = List<PostCommentEntity>.from(data.comments);
          });
          _notifyCommentsChanged(data.commentsCount);
        },
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingComments = false);
    }
  }

  String _formatCommentAuthor(String authorId) {
    if (widget.currentUserId != null && authorId == widget.currentUserId) {
      return context.l10n.youLabel;
    }
    return context.l10n.userLabel;
  }

  String _resolveCommentAuthorLabel(PostCommentEntity comment) {
    if (widget.currentUserId != null &&
        comment.authorId == widget.currentUserId) {
      return context.l10n.youLabel;
    }

    final displayName = comment.authorDisplayName?.trim() ?? '';
    if (displayName.isNotEmpty) {
      return displayName;
    }

    final username = comment.authorUsername?.trim() ?? '';
    if (username.isNotEmpty) {
      return '@$username';
    }

    return _formatCommentAuthor(comment.authorId);
  }

  void _openCommentAuthorProfile(PostCommentEntity comment) {
    final authorId = comment.authorId.trim();
    if (authorId.isEmpty) {
      return;
    }

    final customHandler = widget.onAuthorProfileTap;
    if (customHandler != null) {
      customHandler(authorId);
      return;
    }

    context.pushNamed(
      AppRoutes.otherProfile.name,
      pathParameters: {'userId': authorId},
    );
  }

  bool _hasUsableAuthorMetadata(PostCommentEntity comment) {
    if (widget.currentUserId != null &&
        comment.authorId == widget.currentUserId) {
      return true;
    }

    final displayName = comment.authorDisplayName?.trim() ?? '';
    if (displayName.isNotEmpty) return true;

    final username = comment.authorUsername?.trim() ?? '';
    return username.isNotEmpty;
  }

  Future<void> _submitComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final useCase = getIt<CreateCommentUseCase>();
      final result = await useCase.call(
        CreateCommentParams(
          postId: widget.initialPost.id,
          content: content,
          parentCommentId: _replyTarget?.id,
        ),
      );

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.submitCommentFailed),
            ),
          );
        },
        (comment) {
          if (!mounted) return;
          final nextComments = [..._comments, comment];
          _controller.clear();
          setState(() {
            _commentsVersion++;
            _comments = nextComments;
            _replyTarget = null;
          });
          _notifyCommentsChanged(nextComments.length);
          FocusScope.of(context).unfocus();
        },
      );
    } finally {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  bool _isCommentActionBusy(String commentId) {
    return _commentActionInProgress.contains(commentId);
  }

  Future<void> _openCommentActions(PostCommentEntity comment) async {
    if (_isCommentActionBusy(comment.id)) return;
    final action = await showCommentActionsSheet(context);
    if (!mounted || action == null) return;

    switch (action) {
      case CommentAction.edit:
        await _editComment(comment);
        break;
      case CommentAction.delete:
        await _confirmDeleteComment(comment);
        break;
    }
  }

  Future<void> _editComment(PostCommentEntity comment) async {
    final nextContent = await showEditCommentSheet(
      context,
      initialContent: comment.content,
    );
    if (!mounted || nextContent == null) return;

    final trimmed = nextContent.trim();
    if (trimmed.isEmpty || trimmed == comment.content.trim()) {
      return;
    }

    setState(() {
      _commentActionInProgress.add(comment.id);
    });

    try {
      final useCase = getIt<UpdateCommentUseCase>();
      final result = await useCase.call(
        UpdateCommentParams(
          postId: widget.initialPost.id,
          commentId: comment.id,
          content: trimmed,
        ),
      );

      if (!mounted) return;

      result.fold(
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.updateCommentFailed)),
          );
        },
        (updated) {
          final nextComments = _comments.map((item) {
            if (item.id != comment.id) return item;
            return mergeUpdatedComment(item, updated, trimmed);
          }).toList();
          setState(() {
            _commentsVersion++;
            _comments = nextComments;
          });
          _notifyCommentsChanged(nextComments.length);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.updateCommentSuccess)),
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _commentActionInProgress.remove(comment.id);
        });
      }
    }
  }

  Future<void> _confirmDeleteComment(PostCommentEntity comment) async {
    if (_isCommentActionBusy(comment.id)) return;

    final shouldDelete = await showDeleteCommentConfirmDialog(context);
    if (!mounted || !shouldDelete) return;
    await _deleteComment(comment);
  }

  Future<void> _deleteComment(PostCommentEntity comment) async {
    setState(() {
      _commentActionInProgress.add(comment.id);
    });

    try {
      final useCase = getIt<DeleteCommentUseCase>();
      final result = await useCase.call(
        DeleteCommentParams(
          postId: widget.initialPost.id,
          commentId: comment.id,
        ),
      );

      if (!mounted) return;

      result.fold(
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.deleteCommentFailed)),
          );
        },
        (_) {
          final removal = removeCommentThread(_comments, comment.id);
          setState(() {
            _commentsVersion++;
            _comments = removal.remaining;
            for (final id in removal.removedIds) {
              _commentKeys.remove(id);
            }
            if (_replyTarget != null &&
                removal.removedIds.contains(_replyTarget!.id)) {
              _replyTarget = null;
            }
            if (_activeHighlightCommentId != null &&
                removal.removedIds.contains(_activeHighlightCommentId)) {
              _activeHighlightCommentId = null;
              _pulseController.stop();
            }
          });
          _notifyCommentsChanged(removal.remaining.length);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.deleteCommentSuccess)));
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _commentActionInProgress.remove(comment.id);
        });
      }
    }
  }

  void _notifyCommentsChanged(int commentsCount) {
    final comments = List<PostCommentEntity>.unmodifiable(_comments);
    widget.onCommentsChanged?.call(
      PostCommentsEntity(comments: comments, commentsCount: commentsCount),
    );
    widget.onCommentsCountChanged?.call(commentsCount);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.45,
        initialChildSize: 0.72,
        maxChildSize: 0.95,
        builder: (context, sheetScrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colors.sheetSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Builder(
              builder: (context) {
                final comments = buildFlattenedComments(_comments);
                final replyTarget = _replyTarget;
                _tryInitializeReplyTarget(comments);
                _tryAutoHighlight(comments);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.commentsTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${_comments.length}',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: colors.subtleBorder),
                    Expanded(
                      child: _isLoadingComments && comments.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : comments.isEmpty
                          ? Center(
                              child: Text(
                                context.l10n.noCommentsYet,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                ),
                              ),
                            )
                          : ListView.separated(
                              controller: sheetScrollController,
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                              itemCount: comments.length,
                              separatorBuilder: (_, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = comments[index];
                                final comment = item.comment;
                                final colorScheme = Theme.of(
                                  context,
                                ).colorScheme;
                                final highlightBg = Color.lerp(
                                  colorScheme.primaryContainer,
                                  colorScheme.surface,
                                  0.45,
                                );
                                final indent = (item.depth * 18.0)
                                    .clamp(0.0, 72.0)
                                    .toDouble();
                                final authorLabel = _resolveCommentAuthorLabel(
                                  comment,
                                );
                                final isOwner =
                                    widget.currentUserId != null &&
                                    comment.authorId == widget.currentUserId;
                                final isBusy = _isCommentActionBusy(comment.id);
                                final isHighlighted =
                                    _activeHighlightCommentId == comment.id;
                                final rowKey = _commentKeys.putIfAbsent(
                                  comment.id,
                                  () => GlobalKey(),
                                );

                                return Padding(
                                  key: rowKey,
                                  padding: EdgeInsets.only(left: indent),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 260),
                                    curve: Curves.easeOut,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isHighlighted
                                          ? highlightBg
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              _openCommentAuthorProfile(comment),
                                          child: CommentAvatar(
                                            comment: comment,
                                            authorLabel: authorLabel,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () =>
                                                        _openCommentAuthorProfile(
                                                          comment,
                                                        ),
                                                    child: Text(
                                                      authorLabel,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            colors.textPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    DateFormat(
                                                      'HH:mm dd/MM',
                                                    ).format(comment.createdAt),
                                                    style: TextStyle(
                                                      color:
                                                          colors.textSecondary,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              AnimatedBuilder(
                                                animation: _pulseController,
                                                builder: (context, child) {
                                                  final textColor =
                                                      isHighlighted
                                                      ? Color.lerp(
                                                          colorScheme
                                                              .onPrimaryContainer,
                                                          colorScheme.primary,
                                                          _pulseController
                                                              .value,
                                                        )
                                                      : colorScheme.onSurface;

                                                  return Text(
                                                    comment.content,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      height: 1.3,
                                                      color: textColor,
                                                      fontWeight: isHighlighted
                                                          ? FontWeight.w600
                                                          : FontWeight.w400,
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 4),
                                              InkWell(
                                                onTap: () {
                                                  setState(
                                                    () =>
                                                        _replyTarget = comment,
                                                  );
                                                  _inputFocusNode
                                                      .requestFocus();
                                                },
                                                child: Text(
                                                  _replyTarget?.id == comment.id
                                                      ? context.l10n.replyingStatus
                                                      : context.l10n.replyAction,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: colors.postDetailLink,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isOwner)
                                          IconButton(
                                            onPressed: isBusy
                                                ? null
                                                : () => _openCommentActions(
                                                    comment,
                                                  ),
                                            icon: isBusy
                                                ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : const Icon(
                                                    Icons.more_horiz,
                                                    size: 18,
                                                    color: Colors.black54,
                                                  ),
                                            splashRadius: 18,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (replyTarget != null)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.inputFill,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        context.l10n.replyingTo(_resolveCommentAuthorLabel(replyTarget)),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colors.postDetailLink,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () =>
                                          setState(() => _replyTarget = null),
                                      child: const Padding(
                                        padding: EdgeInsets.all(2),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    key: TestKeys.postCommentTextField,
                                    controller: _controller,
                                    focusNode: _inputFocusNode,
                                    minLines: 1,
                                    maxLines: 4,
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => _submitComment(),
                                    decoration: InputDecoration(
                                      hintText: replyTarget == null
                                          ? context.l10n.writeCommentHint
                                          : context.l10n.writeReplyHint,
                                      filled: true,
                                      fillColor: colors.inputFill,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(22),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  key: TestKeys.postCommentSendButton,
                                  onPressed: _isSubmitting
                                      ? null
                                      : _submitComment,
                                  icon: _isSubmitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.send_rounded),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _tryAutoHighlight(List<FlattenedComment> comments) {
    if (_didAutoHighlight) return;
    final targetId = _activeHighlightCommentId;
    if (targetId == null || targetId.isEmpty) return;

    final exists = comments.any((item) => item.comment.id == targetId);
    if (!exists) return;

    _didAutoHighlight = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetKey = _commentKeys[targetId];
      final targetContext = targetKey?.currentContext;
      if (targetContext == null) return;

      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: 0.2,
      );

      Future.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        if (_activeHighlightCommentId != targetId) return;
        setState(() {
          _activeHighlightCommentId = null;
        });
        _pulseController.stop();
      });
    });
  }

  void _tryInitializeReplyTarget(List<FlattenedComment> comments) {
    if (_didInitializeReplyTarget) return;

    final targetId = widget.initialReplyCommentId?.trim();
    if (targetId == null || targetId.isEmpty) {
      _didInitializeReplyTarget = true;
      return;
    }

    PostCommentEntity? matched;
    for (final item in comments) {
      if (item.comment.id == targetId) {
        matched = item.comment;
        break;
      }
    }

    _didInitializeReplyTarget = true;
    if (matched == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _replyTarget = matched;
      });

      if (widget.autoFocusComposer) {
        _inputFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _inputFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}
