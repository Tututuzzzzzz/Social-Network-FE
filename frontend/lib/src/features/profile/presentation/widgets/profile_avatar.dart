import 'package:flutter/material.dart';

import '../../../../core/utils/url_normalizer.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 42,
    this.onTap,
  });

  final String name;
  final String? avatarUrl;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final normalizedAvatarUrl = avatarUrl?.trim().normalizeClientUrl();
    final hasAvatar =
        normalizedAvatarUrl != null && normalizedAvatarUrl.isNotEmpty;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    final avatar = Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFD8F2E8),
        backgroundImage: hasAvatar ? NetworkImage(normalizedAvatarUrl) : null,
        onBackgroundImageError: hasAvatar ? (_, _) {} : null,
        child: hasAvatar
            ? null
            : Text(
                initial,
                style: TextStyle(
                  color: const Color(0xFF168C68),
                  fontSize: radius * 0.62,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );

    if (onTap == null) {
      return avatar;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: avatar,
    );
  }
}
