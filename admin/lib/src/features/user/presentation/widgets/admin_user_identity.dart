import 'package:flutter/material.dart';

import '../../../../widgets/admin_display_formatters.dart';
import '../../../../widgets/admin_image_viewer_dialog.dart';
import '../../domain/entities/admin_user.dart';

class AdminUserIdentity extends StatelessWidget {
  final AdminUser user;

  const AdminUserIdentity({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: user.avatarUrl == null || user.avatarUrl!.isEmpty
              ? null
              : () => showAdminImageViewer(
                  context: context,
                  imageUrl: user.avatarUrl!,
                  title: user.displayName,
                ),
          child: CircleAvatar(
            radius: 18,
            backgroundImage: user.avatarUrl == null || user.avatarUrl!.isEmpty
                ? null
                : NetworkImage(user.avatarUrl!),
            backgroundColor: const Color(0xFFE6E0D5),
            child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                ? Text(initialFor(user.displayName))
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.displayName),
            Text(
              '@${user.username}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
