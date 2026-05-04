import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/injector/injector.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../widgets/admin_display_formatters.dart';
import '../../../../widgets/admin_empty_state.dart';
import '../../../../widgets/admin_image_viewer_dialog.dart';
import '../../domain/entities/admin_post.dart';
import '../../domain/entities/admin_post_comment.dart';
import '../../domain/entities/admin_post_detail.dart';
import '../../domain/entities/admin_post_media.dart';
import '../bloc/detail/admin_post_detail_cubit.dart';
import '../bloc/detail/admin_post_detail_state.dart';

Future<void> showAdminPostDetailSheet({
  required BuildContext context,
  required AdminPost post,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return BlocProvider(
        create: (_) => injector<AdminPostDetailCubit>()..load(post.id),
        child: Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920, maxHeight: 760),
            child: AdminPostDetailSheet(initialPost: post),
          ),
        ),
      );
    },
  );
}

class AdminPostDetailSheet extends StatelessWidget {
  final AdminPost initialPost;

  const AdminPostDetailSheet({super.key, required this.initialPost});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminPostDetailCubit, AdminPostDetailState>(
      builder: (context, state) {
        final detail = state.detail;
        final post = detail == null
            ? initialPost
            : _mergePost(initialPost: initialPost, detailPost: detail.post);
        final resolvedDetail = detail == null
            ? null
            : AdminPostDetail(post: post, comments: detail.comments);

        return Column(
          children: [
            _PostDetailHeader(post: post),
            const Divider(height: 1),
            Expanded(
              child: switch (state.status) {
                AdminPostDetailStatus.loading ||
                AdminPostDetailStatus.initial => const Center(
                  child: CircularProgressIndicator(),
                ),
                AdminPostDetailStatus.failure => AdminEmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: 'Khong the tai chi tiet bai viet',
                  message: state.message ?? 'Backend request failed.',
                ),
                AdminPostDetailStatus.ready =>
                  resolvedDetail == null
                      ? const AdminEmptyState(
                          icon: Icons.article_outlined,
                          title: 'Khong co du lieu',
                          message: 'Backend khong tra ve chi tiet bai viet.',
                        )
                      : _PostDetailBody(detail: resolvedDetail),
              },
            ),
          ],
        );
      },
    );
  }
}

AdminPost _mergePost({
  required AdminPost initialPost,
  required AdminPost detailPost,
}) {
  final detailAuthorUnknown =
      detailPost.authorUsername.trim().isEmpty ||
      detailPost.authorUsername.trim().toLowerCase() == 'unknown';
  final detailDisplayUnknown =
      detailPost.authorDisplayName.trim().isEmpty ||
      detailPost.authorDisplayName.trim().toLowerCase() == 'unknown';

  return AdminPost(
    id: _prefer(detailPost.id, initialPost.id),
    authorId: _prefer(detailPost.authorId, initialPost.authorId),
    authorUsername: detailAuthorUnknown
        ? initialPost.authorUsername
        : detailPost.authorUsername,
    authorDisplayName: detailDisplayUnknown
        ? initialPost.authorDisplayName
        : detailPost.authorDisplayName,
    authorAvatarUrl: _preferNullable(
      detailPost.authorAvatarUrl,
      initialPost.authorAvatarUrl,
    ),
    content: _prefer(detailPost.content, initialPost.content),
    likesCount: detailPost.likesCount,
    commentsCount: detailPost.commentsCount,
    likeIds: detailPost.likeIds.isEmpty
        ? initialPost.likeIds
        : detailPost.likeIds,
    media: detailPost.media.isEmpty ? initialPost.media : detailPost.media,
    createdAt: detailPost.createdAt,
    updatedAt: detailPost.updatedAt,
  );
}

String _prefer(String primary, String fallback) {
  return primary.trim().isEmpty ? fallback : primary;
}

String? _preferNullable(String? primary, String? fallback) {
  return primary == null || primary.trim().isEmpty ? fallback : primary;
}

class _PostDetailHeader extends StatelessWidget {
  final AdminPost post;

  const _PostDetailHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final avatarUrl = _resolveNetworkUrl(post.authorAvatarUrl);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 14, 18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: avatarUrl == null ? null : NetworkImage(avatarUrl),
            child: avatarUrl == null
                ? Text(initialFor(post.authorDisplayName))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.authorDisplayName, style: textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '@${post.authorUsername} - ${shortId(post.id)}',
                  style: textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Dong',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _PostDetailBody extends StatelessWidget {
  final AdminPostDetail detail;

  const _PostDetailBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    final post = detail.post;

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      children: [
        if (post.content.trim().isNotEmpty) ...[
          Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 18),
        ],
        _PostStats(post: post, commentsCount: detail.totalCommentsCount),
        if (post.media.isNotEmpty) ...[
          const SizedBox(height: 18),
          _PostMediaGrid(media: post.media, postId: post.id),
        ],
        const SizedBox(height: 22),
        Text('Comments', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        if (detail.comments.isEmpty)
          const AdminEmptyState(
            icon: Icons.mode_comment_outlined,
            title: 'Chua co comment',
            message: 'Backend tra ve danh sach comment rong.',
          )
        else
          ...detail.comments.map((comment) => _CommentNode(comment: comment)),
      ],
    );
  }
}

class _PostStats extends StatelessWidget {
  final AdminPost post;
  final int commentsCount;

  const _PostStats({required this.post, required this.commentsCount});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _StatChip(
          icon: Icons.favorite_border,
          label: '${post.likesCount} likes',
        ),
        _StatChip(
          icon: Icons.mode_comment_outlined,
          label: '$commentsCount comments',
        ),
        _StatChip(
          icon: Icons.image_outlined,
          label: '${post.mediaCount} media',
        ),
        _StatChip(
          icon: Icons.schedule_outlined,
          label: formatAdminDate(post.createdAt),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E0D5)),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF7F5EF),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _PostMediaGrid extends StatelessWidget {
  final List<AdminPostMedia> media;
  final String postId;

  const _PostMediaGrid({required this.media, required this.postId});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 680 ? 3 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: media.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 168,
          ),
          itemBuilder: (context, index) {
            final item = media[index];
            final url = _resolveMediaUrl(item);

            if (!item.isImage || url == null) {
              return const _MediaFallback();
            }

            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => showAdminImageViewer(
                context: context,
                imageUrl: url,
                title: shortId(postId),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const _MediaFallback();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

String? _resolveMediaUrl(AdminPostMedia item) {
  return _resolveNetworkUrl(item.mediaUrl) ??
      _resolveNetworkUrl(item.objectKey);
}

String? _resolveNetworkUrl(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) {
    return null;
  }
  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    return raw;
  }

  final baseUri = Uri.tryParse(ApiConstants.baseUrl);
  if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty) {
    return raw;
  }

  final normalizedPath = raw.startsWith('/') ? raw : '/$raw';
  return baseUri.replace(path: normalizedPath, query: '').toString();
}

class _MediaFallback extends StatelessWidget {
  const _MediaFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF7F5EF),
        border: Border.all(color: const Color(0xFFE6E0D5)),
      ),
      child: const Center(child: Icon(Icons.perm_media_outlined)),
    );
  }
}

class _CommentNode extends StatelessWidget {
  final AdminPostComment comment;
  final int depth;

  const _CommentNode({required this.comment, this.depth = 0});

  @override
  Widget build(BuildContext context) {
    final indent = (depth * 18).clamp(0, 72).toDouble();

    return Padding(
      padding: EdgeInsets.only(left: indent, bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE6E0D5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundImage:
                        comment.authorAvatarUrl == null ||
                            comment.authorAvatarUrl!.isEmpty
                        ? null
                        : NetworkImage(comment.authorAvatarUrl!),
                    child:
                        comment.authorAvatarUrl == null ||
                            comment.authorAvatarUrl!.isEmpty
                        ? Text(
                            initialFor(comment.authorDisplayName),
                            style: const TextStyle(fontSize: 11),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      comment.authorDisplayName,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Text(
                    formatAdminDate(comment.createdAt),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(comment.content),
              if (comment.children.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...comment.children.map(
                  (child) => _CommentNode(comment: child, depth: depth + 1),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
