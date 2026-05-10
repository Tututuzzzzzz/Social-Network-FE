import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../post/domain/entities/post_entity.dart';
import '../../../post/presentation/bloc/post/post_bloc.dart';
import '../../../post/presentation/pages/post_detail_screen.dart';
import '../../../post/presentation/widgets/feed_widgets.dart';
import '../bloc/profile/profile_bloc.dart';
import 'profile_empty_state.dart';

class ProfilePostsTab extends StatefulWidget {
  const ProfilePostsTab({
    super.key,
    required this.posts,
    required this.currentUserId,
    this.postsErrorMessage,
    this.onRefresh,
  });

  final List<PostEntity> posts;
  final String currentUserId;
  final String? postsErrorMessage;
  final Future<void> Function()? onRefresh;

  @override
  State<ProfilePostsTab> createState() => _ProfilePostsTabState();
}

class _ProfilePostsTabState extends State<ProfilePostsTab> {
  final Map<String, int> _commentCountOverrides = <String, int>{};

  @override
  void didUpdateWidget(covariant ProfilePostsTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    final visiblePostIds = widget.posts.map((post) => post.id).toSet();
    _commentCountOverrides.removeWhere(
      (postId, _) => !visiblePostIds.contains(postId),
    );

    for (final post in widget.posts) {
      final override = _commentCountOverrides[post.id];
      if (override != null && post.commentsCount >= override) {
        _commentCountOverrides.remove(post.id);
      }
    }
  }

  void _toggleLike(PostEntity post) {
    if (widget.currentUserId.trim().isEmpty) {
      _showFeatureSoon();
      return;
    }

    context.read<ProfileBloc>().add(ProfilePostLikeToggleEvent(post.id));
  }

  Future<void> _openCommentsSheet(PostEntity post) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(
        initialPost: post,
        currentUserId: widget.currentUserId.trim().isEmpty
            ? null
            : widget.currentUserId,
        onCommentsCountChanged: (count) {
          if (!mounted) return;
          setState(() {
            _commentCountOverrides[post.id] = count;
          });
        },
      ),
    );
  }

  Future<void> _openPostDetail(PostEntity post) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => BlocProvider(
          create: (_) => getIt<PostBloc>(),
          child: PostDetailScreen(
            initialPost: post,
            currentUserId: widget.currentUserId.trim().isEmpty
                ? null
                : widget.currentUserId,
          ),
        ),
      ),
    );

    if (!mounted) return;
    await widget.onRefresh?.call();
  }

  void _showFeatureSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.featureInDevelopment)));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh ?? () async {},
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.14),
            ProfileEmptyState(
              icon: widget.postsErrorMessage == null
                  ? Icons.article_outlined
                  : Icons.error_outline_rounded,
              title: widget.postsErrorMessage == null
                  ? context.l10n.noPostsTitle
                  : context.l10n.loadPostsFailed,
              message:
                  widget.postsErrorMessage ??
                  context.l10n.postsEmptyMessage,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh ?? () async {},
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 28),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: widget.posts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final post = widget.posts[index];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openPostDetail(post),
            child: PostCard(
              post: post,
              isLikedByMe:
                  widget.currentUserId.isNotEmpty &&
                  post.likes.contains(widget.currentUserId),
              commentCountOverride: _commentCountOverrides[post.id],
              showFollowButton: false,
              showShareStat: false,
              onLike: () => _toggleLike(post),
              onComment: () => _openCommentsSheet(post),
              onViewComments: () => _openCommentsSheet(post),
              onShare: _showFeatureSoon,
              onSave: _showFeatureSoon,
              onMore: () => _openPostDetail(post),
            ),
          );
        },
      ),
    );
  }
}
