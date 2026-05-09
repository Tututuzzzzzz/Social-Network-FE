import 'package:flutter/material.dart';

import '../../../../../core/l10n/l10n.dart';

enum CreatePostImageEditAction { replace, remove }

Future<CreatePostImageEditAction?> showCreatePostImageOptionsSheet(
  BuildContext context,
) {
  final l10n = context.l10n;

  return showModalBottomSheet<CreatePostImageEditAction>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD7DADE),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.pickFromLibrary),
                onTap: () => Navigator.of(
                  sheetContext,
                ).pop(CreatePostImageEditAction.replace),
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                title: Text(
                  l10n.deleteAction,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                onTap: () => Navigator.of(
                  sheetContext,
                ).pop(CreatePostImageEditAction.remove),
              ),
            ],
          ),
        ),
      );
    },
  );
}
