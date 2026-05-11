import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';

import 'mochi_dm_styles.dart';

class MochiDmTabSwitcher extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const MochiDmTabSwitcher({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _TabItem(
              label: context.l10n.chatAllTab,
              isActive: currentIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: context.l10n.chatGroupsTab,
              isActive: currentIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? MochiDmStyles.primaryGreen
                    : MochiDmStyles.tabInactive,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2.4,
              width: 44,
              decoration: BoxDecoration(
                color: isActive
                    ? MochiDmStyles.primaryGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
