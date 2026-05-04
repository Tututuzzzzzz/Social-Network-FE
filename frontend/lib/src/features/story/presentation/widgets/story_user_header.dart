import 'package:flutter/material.dart';
import '../../../../core/utils/url_normalizer.dart';

class StoryUserHeader extends StatelessWidget {
  final String username;
  final String avatarUrl;
  final VoidCallback onClose;

  const StoryUserHeader({
    super.key,
    required this.username,
    required this.avatarUrl,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedAvatar = avatarUrl.normalizeClientUrl();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: normalizedAvatar.isNotEmpty
                ? NetworkImage(normalizedAvatar)
                : null,
            child: normalizedAvatar.isEmpty ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              username,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
