import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n.dart';

enum PostOwnerAction { edit, delete }

Future<PostOwnerAction?> showPostOwnerActionsSheet(BuildContext context) {
  final l10n = context.l10n;

  return showModalBottomSheet<PostOwnerAction>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.18),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                _OwnerActionTile(
                  label: l10n.editAction,
                  onTap: () => Navigator.pop(sheetContext, PostOwnerAction.edit),
                ),
                _OwnerActionTile(
                  label: l10n.deleteAction,
                  labelColor: const Color(0xFFE53935),
                  onTap: () =>
                      Navigator.pop(sheetContext, PostOwnerAction.delete),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _OwnerActionTile extends StatelessWidget {
  const _OwnerActionTile({
    required this.label,
    required this.onTap,
    this.labelColor = const Color(0xFF111111),
  });

  final String label;
  final VoidCallback onTap;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        ),
      ),
    );
  }
}
