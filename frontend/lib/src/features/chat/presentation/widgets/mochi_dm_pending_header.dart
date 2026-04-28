import 'package:flutter/material.dart';

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
          const Text(
            'Tin nhan dang cho',
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
              foregroundColor: MochiDmStyles.actionBlue,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              showPending ? 'Thu gon' : 'Mo rong',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
