import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';

import 'mochi_dm_styles.dart';

class MochiDmSectionHeader extends StatelessWidget {
  final int pendingCount;
  final bool canTogglePending;
  final VoidCallback onTogglePending;

  const MochiDmSectionHeader({
    super.key,
    required this.pendingCount,
    required this.canTogglePending,
    required this.onTogglePending,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
      child: Row(
        children: [
          Text(
            context.l10n.messagesTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: MochiDmStyles.primaryText,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: canTogglePending ? onTogglePending : null,
            style: TextButton.styleFrom(
              foregroundColor: MochiDmStyles.actionGreen,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              pendingCount == 0
                  ? context.l10n.pendingMessages
                  : context.l10n.pendingMessagesCount(pendingCount.toString()),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
