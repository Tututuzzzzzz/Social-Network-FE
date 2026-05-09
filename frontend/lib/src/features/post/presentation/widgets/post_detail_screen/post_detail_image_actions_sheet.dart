import 'package:flutter/material.dart';

Future<void> showPostDetailImageActionsSheet(
  BuildContext context, {
  required VoidCallback onSaveImage,
  required VoidCallback onCopyImage,
  required VoidCallback onShareImage,
}) {
  return showModalBottomSheet<void>(
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
                _ImageActionTile(
                  label: 'Luu anh',
                  labelColor: const Color(0xFFE53935),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onSaveImage();
                  },
                ),
                _ImageActionTile(
                  label: 'Sao chep anh',
                  labelColor: const Color(0xFFE53935),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onCopyImage();
                  },
                ),
                _ImageActionTile(
                  label: 'Chia se anh',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onShareImage();
                  },
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

class _ImageActionTile extends StatelessWidget {
  const _ImageActionTile({
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
