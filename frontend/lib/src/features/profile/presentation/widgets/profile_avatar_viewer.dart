import 'package:flutter/material.dart';

import '../../../../core/utils/url_normalizer.dart';

enum ProfileAvatarMenuAction { upload, cancel }

class ProfileAvatarViewer extends StatelessWidget {
  const ProfileAvatarViewer({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.canUpdateAvatar = false,
    this.onChangeAvatar,
  });

  final String displayName;
  final String? avatarUrl;
  final bool canUpdateAvatar;
  final VoidCallback? onChangeAvatar;

  @override
  Widget build(BuildContext context) {
    final normalizedAvatarUrl = avatarUrl?.trim().normalizeClientUrl();
    final hasAvatar =
        normalizedAvatarUrl != null && normalizedAvatarUrl.isNotEmpty;
    final initial = displayName.trim().isEmpty
        ? '?'
        : displayName.trim()[0].toUpperCase();

    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Hero(
                  tag: 'profile-avatar-viewer',
                  child: ClipOval(
                    child: SizedBox(
                      width: 286,
                      height: 286,
                      child: hasAvatar
                          ? Image.network(
                              normalizedAvatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _AvatarFallback(initial: initial),
                            )
                          : _AvatarFallback(initial: initial),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              left: 4,
              child: IconButton(
                tooltip: 'Đóng',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: PopupMenuButton<ProfileAvatarMenuAction>(
                tooltip: 'Tùy chọn',
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: Colors.white,
                onSelected: (action) {
                  switch (action) {
                    case ProfileAvatarMenuAction.upload:
                      onChangeAvatar?.call();
                      break;
                    case ProfileAvatarMenuAction.cancel:
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (canUpdateAvatar)
                    const PopupMenuItem(
                      value: ProfileAvatarMenuAction.upload,
                      child: Row(
                        children: [
                          Icon(Icons.upload_rounded),
                          SizedBox(width: 10),
                          Text('Tải ảnh đại diện mới'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: ProfileAvatarMenuAction.cancel,
                    child: Row(
                      children: [
                        Icon(Icons.close_rounded),
                        SizedBox(width: 10),
                        Text('Hủy'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFD8F2E8),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Color(0xFF168C68),
            fontSize: 116,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
