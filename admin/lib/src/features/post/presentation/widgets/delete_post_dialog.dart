import 'package:flutter/material.dart';

import '../../domain/entities/admin_post.dart';

Future<bool> showDeletePostDialog({
  required BuildContext context,
  required AdminPost post,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Xóa bài viết'), // 'Delete Post'
        content: Text(
          'Bạn có chắc chắn muốn xóa bài viết của ${post.authorUsername}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'), // 'Cancel'
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Xóa'), // 'Delete'
          ),
        ],
      );
    },
  );

  return confirmed == true;
}
