import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostDetailContent extends StatelessWidget {
  const PostDetailContent({
    super.key,
    required this.authorUsername,
    required this.authorId,
    required this.currentUserId,
    required this.isFollowing,
    required this.sendingFollowRequest,
    required this.isLiked,
    required this.likesCount,
    required this.commentCount,
    required this.content,
    required this.createdAt,
    required this.onFollowTap,
    required this.onLikeTap,
    required this.onCommentsTap,
  });

  final String authorUsername;
  final String authorId;
  final String currentUserId;
  final bool isFollowing;
  final bool sendingFollowRequest;
  final bool isLiked;
  final int likesCount;
  final int commentCount;
  final String? content;
  final DateTime createdAt;
  final VoidCallback onFollowTap;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AuthorRow(
            authorUsername: authorUsername,
            authorId: authorId,
            currentUserId: currentUserId,
            isFollowing: isFollowing,
            sendingFollowRequest: sendingFollowRequest,
            onFollowTap: onFollowTap,
          ),
          const SizedBox(height: 8),
          _PostStatsRow(
            isLiked: isLiked,
            likesCount: likesCount,
            commentCount: commentCount,
            onLikeTap: onLikeTap,
            onCommentsTap: onCommentsTap,
          ),
          if ((content ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(content!.trim(), style: const TextStyle(height: 1.3)),
          ],
          const SizedBox(height: 6),
          Text(
            DateFormat('MMM d, yyyy').format(createdAt),
            style: const TextStyle(color: Color(0xFFA2A2A8), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({
    required this.authorUsername,
    required this.authorId,
    required this.currentUserId,
    required this.isFollowing,
    required this.sendingFollowRequest,
    required this.onFollowTap,
  });

  final String authorUsername;
  final String authorId;
  final String currentUserId;
  final bool isFollowing;
  final bool sendingFollowRequest;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final showFollow = currentUserId.isNotEmpty && authorId != currentUserId;

    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFFE7E7E7),
          child: Text(
            authorUsername.isEmpty ? '?' : authorUsername[0].toUpperCase(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            authorUsername,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        // if (showFollow)
        //   GestureDetector(
        //     onTap: isFollowing || sendingFollowRequest ? null : onFollowTap,
        //     child: Text(
        //       isFollowing ? 'Following' : 'Follow',
        //       style: TextStyle(
        //         fontSize: 13,
        //         fontWeight: FontWeight.w600,
        //         color: isFollowing ? Colors.black54 : const Color(0xFF246BCE),
        //       ),
        //     ),
        //   ),
      ],
    );
  }
}

class _PostStatsRow extends StatelessWidget {
  const _PostStatsRow({
    required this.isLiked,
    required this.likesCount,
    required this.commentCount,
    required this.onLikeTap,
    required this.onCommentsTap,
  });

  final bool isLiked;
  final int likesCount;
  final int commentCount;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onLikeTap,
          child: Row(
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: isLiked ? Colors.red : Colors.black,
              ),
              const SizedBox(width: 4),
              Text(
                _formatCount(likesCount),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onCommentsTap,
          child: Row(
            children: [
              const Icon(Icons.chat_bubble_outline, size: 20),
              const SizedBox(width: 4),
              Text(
                _formatCount(commentCount),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.send_rounded, size: 20),
        const Spacer(),
        const Icon(Icons.bookmark_border, size: 20),
      ],
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
