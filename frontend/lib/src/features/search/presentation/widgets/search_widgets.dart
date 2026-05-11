import 'package:flutter/material.dart';
import '../../domain/entities/search_entity.dart';
import '../../../../core/theme/app_colors.dart';

class SearchResultCard extends StatelessWidget {
  final SearchEntity user;
  final VoidCallback onTap;

  const SearchResultCard({
    Key? key,
    required this.user,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(user.avatarUrl),
              onBackgroundImageError: (_, __) {},
              child: user.avatarUrl.isEmpty
              ? Icon(Icons.person, color: colors.appBarForeground)
                  : null,
            ),
            const SizedBox(width: 12),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.username.isNotEmpty)
                    Text(
                      '@${user.username}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (user.bio.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        user.bio,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.more_vert,
              color: colors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class SearchHistoryItem extends StatelessWidget {
  final SearchHistoryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const SearchHistoryItem({
    Key? key,
    required this.entry,
    required this.onTap,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final avatarUrl = entry.avatarUrl?.trim() ?? '';
    final showAvatar = entry.isUser;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (showAvatar)
              CircleAvatar(
                radius: 12,
                backgroundColor: colors.avatarPlaceholder,
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 14,
                        color: colors.appBarForeground,
                      )
                    : null,
              )
            else
              Icon(Icons.history, color: colors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.label,
                style: TextStyle(
                  fontSize: 15,
                  color: colors.textPrimary,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 18, color: colors.textSecondary),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
