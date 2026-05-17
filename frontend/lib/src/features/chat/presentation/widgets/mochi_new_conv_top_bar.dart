import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/theme/app_colors.dart';

import 'mochi_dm_search_input.dart';

/// Top bar dùng cho MochiNewConversationPage.
/// Gồm: back button, tiêu đề, search input.
class MochiNewConvTopBar extends StatelessWidget {
  const MochiNewConvTopBar({
    super.key,
    required this.onSearchChanged,
  });

  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      color: colors.primary,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                ),
                color: colors.appBarForeground,
              ),
              Expanded(
                child: Text(
                  context.l10n.newConversationTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.appBarForeground,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          MochiDmSearchInput(
            onChanged: onSearchChanged,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            fillColor: colors.authGoogleButton,
            hintColor: colors.textSecondary,
            iconColor: colors.accent,
            focusedBorderColor: colors.inputBorder,
            borderRadius: 16,
            hintText: context.l10n.searchFriends,
            dense: true,
          ),
        ],
      ),
    );
  }
}
