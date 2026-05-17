import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/theme/app_colors.dart';

import 'mochi_dm_search_input.dart';

class MochiDmTopBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onEditPressed;
  final VoidCallback? onBackPressed;

  const MochiDmTopBar({
    super.key,
    required this.onSearchChanged,
    required this.onEditPressed,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      color: colors.primary,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            IconButton(
              onPressed:
                  onBackPressed ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              color: colors.appBarForeground,
            ),
            Expanded(
              child: MochiDmSearchInput(
                onChanged: onSearchChanged,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 4,
                ),
                fillColor: colors.authGoogleButton,
                hintColor: colors.textSecondary,
                iconColor: colors.accent,
                focusedBorderColor: colors.inputBorder,
                borderRadius: 16,
                hintText: context.l10n.searchInMessages,
                dense: true,
              ),
            ),
            IconButton(
              onPressed: onEditPressed,
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: colors.appBarForeground,
            ),
          ],
        ),
      ),
    );
  }
}
