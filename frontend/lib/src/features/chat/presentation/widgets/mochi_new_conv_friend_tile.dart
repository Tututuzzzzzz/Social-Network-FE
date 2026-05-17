import 'package:flutter/material.dart';

import '../../../../core/utils/url_normalizer.dart';
import '../../../friend/presentation/pages/friend_picker_bottom_sheet.dart';
import 'package:frontend/src/core/testing/test_keys.dart';

/// ListTile hiển thị 1 người bạn trong danh sách tạo hội thoại trực tiếp.
class MochiNewConvFriendTile extends StatelessWidget {
  const MochiNewConvFriendTile({
    super.key,
    required this.friend,
    required this.onTap,
    required this.index,
  });

  final FriendPickerUser friend;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    final avatar = friend.avatarUrl.normalizeClientUrl();
    final hasAvatar = avatar.isNotEmpty;

    return ListTile(
      key: TestKeys.newConversationFriend(index),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE8EBF4),
        backgroundImage: hasAvatar ? NetworkImage(avatar) : null,
        child: hasAvatar
            ? null
            : Text(
                friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?',
              ),
      ),
      title: Text(friend.name),
      subtitle:
          friend.username.isEmpty ? null : Text('@${friend.username}'),
      trailing: const Icon(Icons.chat_bubble_outline, size: 20),
      onTap: onTap,
    );
  }
}
