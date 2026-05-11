import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/theme/app_colors.dart';

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
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    final normalizedAvatarUrl = avatarUrl?.trim().normalizeClientUrl();
    final hasAvatar =
        normalizedAvatarUrl != null && normalizedAvatarUrl.isNotEmpty;
    final initial = displayName.trim().isEmpty
        ? '?'
        : displayName.trim()[0].toUpperCase();

    return Dialog.fullscreen(
      backgroundColor: colors.mediaBackground,
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
                tooltip: l10n.cancel,
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: colors.postDetailText),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: PopupMenuButton<ProfileAvatarMenuAction>(
                tooltip: l10n.optionsLabel,
                icon: Icon(Icons.more_vert, color: colors.postDetailText),
                color: colors.sheetSurface,
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
                    PopupMenuItem(
                      value: ProfileAvatarMenuAction.upload,
                      child: Row(
                        children: [
                          Icon(Icons.upload_rounded, color: colors.textPrimary),
                          const SizedBox(width: 10),
                          Text(
                            l10n.editAvatarAction,
                            style: TextStyle(color: colors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: ProfileAvatarMenuAction.cancel,
                    child: Row(
                      children: [
                        Icon(Icons.close_rounded, color: colors.textPrimary),
                        const SizedBox(width: 10),
                        Text(
                          l10n.cancel,
                          style: TextStyle(color: colors.textPrimary),
                        ),
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
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.avatarPlaceholder,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: colors.accent,
            fontSize: 116,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
