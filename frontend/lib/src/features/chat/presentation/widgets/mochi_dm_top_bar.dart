import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';

import 'mochi_dm_styles.dart';
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
    return Container(
      color: MochiDmStyles.primaryGreen,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            IconButton(
              onPressed:
                  onBackPressed ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              color: MochiDmStyles.topBarText,
            ),
            Expanded(
              child: MochiDmSearchInput(
                onChanged: onSearchChanged,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 4,
                ),
                fillColor: MochiDmStyles.searchBackground,
                hintColor: MochiDmStyles.searchHint,
                iconColor: MochiDmStyles.searchIcon,
                focusedBorderColor: MochiDmStyles.primaryGreenSoft,
                borderRadius: 16,
                hintText: context.l10n.searchInMessages,
                dense: true,
              ),
            ),
            IconButton(
              onPressed: onEditPressed,
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: MochiDmStyles.topBarText,
            ),
          ],
        ),
      ),
    );
  }
}
