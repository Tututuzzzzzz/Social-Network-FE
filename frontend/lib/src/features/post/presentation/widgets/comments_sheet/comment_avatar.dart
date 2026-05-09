import 'package:flutter/material.dart';
import 'package:frontend/src/core/utils/url_normalizer.dart';
import 'package:frontend/src/features/post/domain/entities/post_comment_entity.dart';

class CommentAvatar extends StatelessWidget {
  const CommentAvatar({super.key, required this.comment, required this.authorLabel});

  final PostCommentEntity comment;
  final String authorLabel;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = comment.authorAvatarUrl?.trim().normalizeClientUrl() ?? '';
    final initial = _resolveInitial(authorLabel);

    if (avatarUrl.isEmpty) {
      return _FallbackCommentAvatar(initial: initial);
    }

    return ClipOval(
      child: Image.network(
        avatarUrl,
        width: 28,
        height: 28,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _FallbackCommentAvatar(initial: initial),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _FallbackCommentAvatar(initial: initial);
        },
      ),
    );
  }

  String _resolveInitial(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return '?';

    final withoutPrefix = normalized.startsWith('@')
        ? normalized.substring(1).trim()
        : normalized;
    if (withoutPrefix.isEmpty) return '?';

    return withoutPrefix[0].toUpperCase();
  }
}

class _FallbackCommentAvatar extends StatelessWidget {
  const _FallbackCommentAvatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: const Color(0xFFE7E7E7),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }
}
