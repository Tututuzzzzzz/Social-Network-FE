import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';

import 'mochi_dm_styles.dart';

class MochiDmPendingHeader extends StatelessWidget {
  final bool showPending;
  final VoidCallback onToggle;

  const MochiDmPendingHeader({
    super.key,
    required this.showPending,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Text(
            context.l10n.pendingMessages,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: MochiDmStyles.primaryText,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onToggle,
            style: TextButton.styleFrom(
              foregroundColor: MochiDmStyles.actionGreen,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              showPending ? context.l10n.collapseAction : context.l10n.expandAction,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
