import 'package:flutter/material.dart';

class HomeComposerCard extends StatelessWidget {
  final String avatarInitial;
  final String promptText;
  final VoidCallback? onTapPrompt;
  final VoidCallback? onTapImage;

  const HomeComposerCard({
    super.key,
    this.avatarInitial = 'Y',
    this.promptText = 'What is happening today?',
    this.onTapPrompt,
    this.onTapImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF6F8FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(radius: 18, child: Text(avatarInitial)),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onTapPrompt,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    promptText,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onTapImage,
              icon: const Icon(Icons.image_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
