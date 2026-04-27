import 'package:flutter/material.dart';
import '../../../domain/entities/admin_post.dart';
import '../common/admin_display_formatters.dart';

class AdminPostSummary extends StatelessWidget {
  final AdminPost post;

  const AdminPostSummary({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final content = post.content.trim().isEmpty ? '(media post)' : post.content;

    return SizedBox(
      width: 360,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(
            '${post.mediaCount} media - ${shortId(post.id)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
