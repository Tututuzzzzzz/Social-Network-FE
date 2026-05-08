import 'package:flutter/material.dart';

class MessageChatRoomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const MessageChatRoomAppBar({
    super.key,
    required this.title,
    required this.accentColor,
    required this.onBack,
    this.onCall,
    this.onVideoCall,
  });

  final String title;
  final Color accentColor;
  final VoidCallback onBack;
  final VoidCallback? onCall;
  final VoidCallback? onVideoCall;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final displayTitle = title.trim().isEmpty ? 'Conversation' : title;
    final leadingChar = displayTitle.isNotEmpty ? displayTitle[0] : '?';

    return AppBar(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      ),
      centerTitle: false,
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Text(
              leadingChar,
              style: TextStyle(color: accentColor, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              displayTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onCall ?? () {},
          icon: const Icon(Icons.call_outlined),
        ),
        IconButton(
          onPressed: onVideoCall ?? () {},
          icon: const Icon(Icons.videocam_outlined),
        ),
      ],
    );
  }
}
