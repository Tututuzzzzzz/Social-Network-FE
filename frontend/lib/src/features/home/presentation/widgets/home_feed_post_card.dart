import 'package:flutter/material.dart';

class HomePostItem {
  final String author;
  final int minutesAgo;
  final String content;
  final int likes;
  final int comments;
  final String mediaUrl;

  const HomePostItem({
    required this.author,
    required this.minutesAgo,
    required this.content,
    required this.likes,
    required this.comments,
    this.mediaUrl = '',
  });
}

class HomeFeedPostCard extends StatelessWidget {
  final HomePostItem item;
  final VoidCallback? onTapMore;
  final VoidCallback? onTapLike;
  final VoidCallback? onTapComment;
  final VoidCallback? onTapShare;

  const HomeFeedPostCard({
    super.key,
    required this.item,
    this.onTapMore,
    this.onTapLike,
    this.onTapComment,
    this.onTapShare,
  });

  String _formatTimeAgo(int minutesAgo) {
    if (minutesAgo < 1) {
      return 'now';
    }
    if (minutesAgo < 60) {
      return '${minutesAgo}m ago';
    }

    final hours = minutesAgo ~/ 60;
    if (hours < 24) {
      return '${hours}h ago';
    }

    final days = hours ~/ 24;
    return '${days}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  child: Text(item.author.substring(0, 1)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.author,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _formatTimeAgo(item.minutesAgo),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onTapMore,
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.content),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.mediaUrl.isEmpty
                  ? Container(
                      height: 160,
                      color: const Color(0xFFE8EEF5),
                      alignment: Alignment.center,
                      child: const Icon(Icons.photo_outlined, size: 38),
                    )
                  : Image.network(
                      item.mediaUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 160,
                          color: const Color(0xFFE8EEF5),
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_outlined),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${item.likes} likes'),
                const SizedBox(width: 12),
                Text('${item.comments} comments'),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: onTapLike,
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Like'),
                ),
                TextButton.icon(
                  onPressed: onTapComment,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Comment'),
                ),
                TextButton.icon(
                  onPressed: onTapShare,
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
