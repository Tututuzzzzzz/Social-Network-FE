import 'package:flutter/material.dart';

import '../../domain/entities/profile_entity.dart';
import 'profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    required this.postsCount,
    this.onAvatarTap,
  });

  final ProfileEntity profile;
  final int postsCount;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final displayName = _resolveDisplayName(profile);
    final username = profile.username?.trim() ?? '';
    final bio = profile.bio?.trim();

    return Container(
      color: const Color(0xFFEAF2FF),
      child: Stack(
        children: [
          const Positioned.fill(child: _HeaderStripes()),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 30, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ProfileAvatar(
                      name: displayName,
                      avatarUrl: profile.avatarUrl,
                      radius: 43,
                      onTap: onAvatarTap,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: const Color(0xFF14221D),
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFFF5B848),
                                  size: 18,
                                ),
                              ],
                            ),
                            if (username.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                '@$username',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF5E6A73),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  bio == null || bio.isEmpty ? 'Chưa có giới thiệu.' : bio,
                  style: const TextStyle(
                    color: Color(0xFF33413D),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _ProfileMetric(
                        icon: Icons.group_rounded,
                        value: profile.friendsCount,
                        label: 'Bạn bè',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProfileMetric(
                        icon: Icons.article_rounded,
                        value: postsCount,
                        label: 'Bài viết',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _resolveDisplayName(ProfileEntity profile) {
    final displayName = profile.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final username = profile.username?.trim();
    if (username != null && username.isNotEmpty) {
      return username;
    }

    return 'Người dùng';
  }
}

class _HeaderStripes extends StatelessWidget {
  const _HeaderStripes();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Expanded(
          child: ColoredBox(
            color: index.isEven
                ? const Color(0xFFEAF2FF)
                : const Color(0xFFF7FAFF),
          ),
        );
      }),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D5848).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFDDF8ED),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFF25A97A), size: 19),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatCount(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF14221D),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF61706C),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      final value = count / 1000000;
      return '${value.toStringAsFixed(value >= 10 ? 0 : 1)}M';
    }
    if (count >= 1000) {
      final value = count / 1000;
      return '${value.toStringAsFixed(value >= 10 ? 0 : 1)}K';
    }
    return count.toString();
  }
}
