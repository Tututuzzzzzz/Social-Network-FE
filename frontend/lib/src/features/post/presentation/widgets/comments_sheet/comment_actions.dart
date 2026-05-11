import 'package:flutter/material.dart';
import 'package:frontend/src/core/theme/app_colors.dart';

enum CommentAction { edit, delete }

Future<CommentAction?> showCommentActionsSheet(BuildContext context) {
  final colors = AppColors.of(context);
  return showModalBottomSheet<CommentAction>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: colors.scrim,
    isScrollControlled: false,
    builder: (sheetContext) {
      final sheetColors = AppColors.of(sheetContext);
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: sheetColors.sheetSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 34,
                  height: 3,
                  decoration: BoxDecoration(
                    color: sheetColors.sheetHandle,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: sheetColors.textPrimary,
                  ),
                  title: Text(
                    'Chinh sua',
                    style: TextStyle(color: sheetColors.textPrimary),
                  ),
                  onTap: () => Navigator.pop(sheetContext, CommentAction.edit),
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: sheetColors.error,
                  ),
                  title: Text(
                    'Xoa',
                    style: TextStyle(color: sheetColors.error),
                  ),
                  onTap: () => Navigator.pop(sheetContext, CommentAction.delete),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<String?> showEditCommentSheet(
  BuildContext context, {
  required String initialContent,
}) async {
  final controller = TextEditingController(text: initialContent);
  final focusNode = FocusNode();

  final result = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final colors = AppColors.of(sheetContext);
      return AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.sheetSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chinh sua binh luan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller,
                      focusNode: focusNode,
                      minLines: 2,
                      maxLines: 4,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'Nhap noi dung...',
                        filled: true,
                        fillColor: colors.inputFill,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('Huy'),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(
                            sheetContext,
                            controller.text.trim(),
                          ),
                          child: const Text('Luu'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  controller.dispose();
  focusNode.dispose();
  return result?.trim();
}

Future<bool> showDeleteCommentConfirmDialog(BuildContext context) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Xoa binh luan?'),
        content: const Text('Hanh dong nay khong the hoan tac.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Huy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xoa'),
          ),
        ],
      );
    },
  );

  return shouldDelete == true;
}
