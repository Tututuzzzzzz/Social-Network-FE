import 'package:flutter/material.dart';

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
          const Text(
            'Tin nhan',
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
              foregroundColor: MochiDmStyles.actionBlue,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              pendingCount == 0
                  ? 'Tin nhan dang cho'
                  : 'Tin nhan dang cho ($pendingCount)',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
