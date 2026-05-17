import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/utils/url_normalizer.dart';
import 'package:frontend/src/core/theme/app_colors.dart';
import 'package:frontend/src/widgets/follow_status_chip.dart';
import 'package:intl/intl.dart';
import 'package:frontend/src/core/testing/test_keys.dart';

import '../../../domain/entities/post_entity.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.authorName,
    this.authorUsername,
    this.authorAvatarUrl,
    this.locationLabel,
    this.isVerified = false,
    this.isLikedByMe = false,
    this.likeCountOverride,
    this.commentCountOverride,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
    this.onMore,
    this.onViewComments,
    this.followingLabel,
    this.followLabel,
    this.isFollowing = true,
    this.showFollowButton = true,
    this.showShareAction = true,
    this.showShareStat = true,
    this.onFollowTap,
    this.onAuthorTap,
  });

  final PostEntity post;
  final String? authorName;
  final String? authorUsername;
  final String? authorAvatarUrl;
  final String? locationLabel;
  final bool isVerified;
  final bool isLikedByMe;
  final int? likeCountOverride;
  final int? commentCountOverride;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onMore;
  final VoidCallback? onViewComments;
  final String? followingLabel;
  final String? followLabel;
  final bool isFollowing;
  final bool showFollowButton;
  final bool showShareAction;
  final bool showShareStat;
  final VoidCallback? onFollowTap;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final likesCount = likeCountOverride ?? post.likes.length;
    final commentCount = commentCountOverride ?? post.commentsCount;
    final imageUrls = _resolveImageUrls();
    final content = post.content?.trim();

    final displayName = (authorName != null && authorName!.trim().isNotEmpty)
        ? authorName!.trim()
        : ((post.authorDisplayName != null &&
                  post.authorDisplayName!.trim().isNotEmpty)
              ? post.authorDisplayName!.trim()
              : _formatFallbackName(post.authorId));

    final avatarUrl =
        (authorAvatarUrl != null && authorAvatarUrl!.trim().isNotEmpty)
        ? authorAvatarUrl!.trim()
        : post.authorAvatarUrl;

    return Container(
      color: colors.sheetSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 8),
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onAuthorTap,
                  child: _UserAvatar(name: displayName, avatarUrl: avatarUrl),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onAuthorTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              displayName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                                fontSize: 14,
                                letterSpacing: -0.1,
                              ),
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.verified,
                                size: 16,
                                color: colors.postDetailLink,
                              ),
                            ],
                          ],
                        ),
                        if (locationLabel != null && locationLabel!.isNotEmpty)
                          Text(
                            locationLabel!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                          )
                        else
                          Text(
                            DateFormat('d MMMM', Localizations.localeOf(context).languageCode).format(post.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (showFollowButton) ...[
                  FollowStatusChip(
                    isFollowing: isFollowing,
                    followingText:
                        followingLabel ?? "",
                    followText: followLabel ?? "",
                  ),
                  const SizedBox(width: 4),
                ],
                IconButton(
                  visualDensity: VisualDensity.compact,
                  splashRadius: 18,
                  icon: Icon(Icons.more_horiz, color: colors.textPrimary),
                  onPressed: onMore,
                ),
              ],
            ),
          ),

          if (content != null && content.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                14,
                0,
                14,
                imageUrls.isEmpty ? 10 : 8,
              ),
              child: Text.rich(
                TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                    height: 1.45,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [TextSpan(text: content)],
                ),
              ),
            ),
          _PostMedia(imageUrls: imageUrls),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      context.l10n.likesCount(_formatCount(likesCount)),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      context.l10n.commentsCount(_formatCount(commentCount)),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (showShareStat) ...[
                      const Spacer(),
                      Text(
                        context.l10n.sharesCount('1'), // Placeholder for now
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Divider(height: 1, thickness: 1, color: colors.subtleBorder),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BottomAction(
                      key: TestKeys.postLikeButton,
                      icon: isLikedByMe
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: isLikedByMe
                          ? colors.likeActive
                          : colors.textPrimary,
                      label: context.l10n.likeAction,
                      onTap: onLike,
                    ),
                    _BottomAction(
                      key: TestKeys.postCommentButton,
                      icon: Icons.chat_bubble_outline,
                      label: context.l10n.commentAction,
                      onTap: onComment,
                    ),
                    if (showShareAction)
                      _BottomAction(
                        icon: Icons.send,
                        label: context.l10n.shareAction,
                        onTap: onShare,
                      ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: colors.subtleBorder),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  List<String> _resolveImageUrls() {
    if (post.media.isEmpty) return const [];

    final results = <String>[];

    for (final item in post.media) {
      final mediaUrl = item.mediaUrl?.trim();
      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        results.add(mediaUrl.normalizeClientUrl());
        continue;
      }

      final key = item.objectKey.trim();
      if (key.isEmpty) {
        continue;
      }

      if (key.startsWith('http://') || key.startsWith('https://')) {
        results.add(key.normalizeClientUrl());
      }
    }

    return results;
  }

  String _formatFallbackName(String authorId) {
    if (authorId.isEmpty) return 'User';
    if (authorId.length <= 10) return authorId;
    return 'User ${authorId.substring(0, 6)}';
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
}

class _PostMedia extends StatefulWidget {
  const _PostMedia({required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<_PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<_PostMedia> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant _PostMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrls.length != oldWidget.imageUrls.length &&
        _currentIndex >= widget.imageUrls.length) {
      setState(() {
        _currentIndex = 0;
      });
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    if (widget.imageUrls.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: colors.inputFill,
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 48,
              color: colors.placeholderIcon,
            ),
          ),
        ),
      );
    }

    if (widget.imageUrls.length == 1) {
      return AspectRatio(
        aspectRatio: 1,
        child: _buildNetworkImage(widget.imageUrls.first, colors),
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildNetworkImage(widget.imageUrls[index], colors);
            },
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.mediaBackground.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.imageUrls.length}',
                style: TextStyle(
                  color: colors.postDetailText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageUrls.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 8 : 6,
                  height: isActive ? 8 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? colors.postDetailText
                        : colors.postDetailText.withValues(alpha: 0.6),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl, AppColors colors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: colors.inputFill,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: colors.inputFill,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 48,
                color: colors.placeholderIcon,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();
    final hasNetwork = avatarUrl != null && avatarUrl!.trim().isNotEmpty;
    final normalizedAvatarUrl = hasNetwork
        ? avatarUrl!.trim().normalizeClientUrl()
        : null;

    if (!hasNetwork) {
      return CircleAvatar(
        radius: 23,
        backgroundColor: colors.avatarPlaceholder,
        child: Text(
          initial,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            fontSize: 12,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 23,
      backgroundColor: colors.avatarPlaceholder,
      backgroundImage: NetworkImage(normalizedAvatarUrl!),
      onBackgroundImageError: (exception, stackTrace) {},
      child: null,
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    super.key,
    required this.icon,
    this.color,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final Color? color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 26, color: color ?? colors.textPrimary),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
