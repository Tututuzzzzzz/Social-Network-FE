import 'package:flutter/material.dart';
import 'package:frontend/src/core/theme/app_colors.dart';

import '../../../../core/utils/url_normalizer.dart';
import '../../../friend/presentation/pages/friend_picker_bottom_sheet.dart';

/// ListTile hiển thị 1 người bạn trong danh sách tạo hội thoại trực tiếp.
class MochiNewConvFriendTile extends StatelessWidget {
  const MochiNewConvFriendTile({
    super.key,
    required this.friend,
    required this.onTap,
  });

  final FriendPickerUser friend;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final avatar = friend.avatarUrl.normalizeClientUrl();
    final hasAvatar = avatar.isNotEmpty;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colors.avatarPlaceholder,
        backgroundImage: hasAvatar ? NetworkImage(avatar) : null,
        child: hasAvatar
            ? null
            : Text(
                friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?',
              ),
      ),
      title: Text(
        friend.name,
        style: TextStyle(color: colors.textPrimary),
      ),
      subtitle:
          friend.username.isEmpty
              ? null
              : Text(
                  '@${friend.username}',
                  style: TextStyle(color: colors.textSecondary),
                ),
      trailing: Icon(
        Icons.chat_bubble_outline,
        size: 20,
        color: colors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
