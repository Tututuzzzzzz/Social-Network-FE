import 'package:flutter/material.dart';

import '../../../../../core/api/api_constants.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import '../../../../../core/utils/url_normalizer.dart';
import 'create_post_theme.dart';

class CreatePostHeader extends StatelessWidget {
  const CreatePostHeader({
    super.key,
    required this.displayName,
    required this.avatarUrl,
    required this.isSubmitting,
    required this.canSubmit,
    required this.onClose,
    required this.onSubmit,
  });

  final String displayName;
  final String avatarUrl;
  final bool isSubmitting;
  final bool canSubmit;
  final VoidCallback onClose;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final hasDisplayName = displayName.trim().isNotEmpty;

    return SizedBox(
      height: 92,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(19, 18, 24, 12),
        child: Row(
          children: [
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 32, color: Color(0xFF7A7F87)),
              splashRadius: 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 42, height: 42),
            ),
            const SizedBox(width: 8),
            _CurrentUserAvatar(name: displayName, avatarUrl: avatarUrl),
            const SizedBox(width: 14),
            Expanded(
              child: hasDisplayName
                  ? Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CreatePostTheme.textColor,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: 0,
                      ),
                    )
                  : const _HeaderNamePlaceholder(),
            ),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: (isSubmitting || !canSubmit) ? null : onSubmit,
              style: ButtonStyle(
                minimumSize: const WidgetStatePropertyAll(Size(92, 50)),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 22),
                ),
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return CreatePostTheme.accentColor.withValues(alpha: 0.56);
                  }
                  return CreatePostTheme.accentColor;
                }),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
                shape: const WidgetStatePropertyAll(StadiumBorder()),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      context.l10n.postAction,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentUserAvatar extends StatelessWidget {
  const _CurrentUserAvatar({required this.name, required this.avatarUrl});

  final String name;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final normalizedAvatarUrl = _normalizeClientMediaUrl(avatarUrl);
    final initial = name.trim().isEmpty ? '' : name.trim()[0].toUpperCase();

    return CircleAvatar(
      radius: 25,
      backgroundColor: const Color(0xFFDADDE2),
      backgroundImage: normalizedAvatarUrl.isNotEmpty
          ? NetworkImage(normalizedAvatarUrl)
          : null,
      onBackgroundImageError: normalizedAvatarUrl.isNotEmpty ? (_, _) {} : null,
      child: normalizedAvatarUrl.isEmpty && initial.isNotEmpty
          ? Text(
              initial,
              style: const TextStyle(
                color: Color(0xFF303842),
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            )
          : null,
    );
  }
}

class _HeaderNamePlaceholder extends StatelessWidget {
  const _HeaderNamePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 124,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFFE7EAEE),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

String _normalizeClientMediaUrl(String? url) {
  final raw = (url ?? '').trim();
  if (raw.isEmpty) return '';
  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    return normalizeClientNetworkUrl(raw);
  }

  final apiUri = Uri.parse(ApiConstants.baseUrl);
  final origin =
      '${apiUri.scheme}://${apiUri.host}${apiUri.hasPort ? ':${apiUri.port}' : ''}';
  final full = raw.startsWith('/') ? '$origin$raw' : '$origin/$raw';
  return normalizeClientNetworkUrl(full);
}
