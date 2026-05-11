import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class ProfileAvatarUploadDraft {
  const ProfileAvatarUploadDraft({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

Future<ProfileAvatarUploadDraft?> showProfileAvatarUploadSheet(
  BuildContext context,
) {
  return showModalBottomSheet<ProfileAvatarUploadDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.of(context).scrim,
    builder: (_) => const _ProfileAvatarUploadSheet(),
  );
}

class _ProfileAvatarUploadSheet extends StatefulWidget {
  const _ProfileAvatarUploadSheet();

  @override
  State<_ProfileAvatarUploadSheet> createState() =>
      _ProfileAvatarUploadSheetState();
}

class _ProfileAvatarUploadSheetState extends State<_ProfileAvatarUploadSheet> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedBytes;
  String? _selectedFileName;
  bool _isPicking = false;

  Future<void> _pickImage() async {
    if (_isPicking) return;

    setState(() => _isPicking = true);
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
        maxWidth: 1600,
      );

      if (image == null || !mounted) return;

      final bytes = await image.readAsBytes();
      if (!mounted) return;

      setState(() {
        _selectedBytes = bytes;
        _selectedFileName =
            image.name.trim().isEmpty ? 'avatar.jpg' : image.name.trim();
      });
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  void _confirm() {
    final bytes = _selectedBytes;
    final fileName = _selectedFileName;
    if (bytes == null || fileName == null || fileName.isEmpty) return;

    Navigator.of(context).pop(
      ProfileAvatarUploadDraft(bytes: bytes, fileName: fileName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _selectedBytes;
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      minChildSize: 0.48,
      initialChildSize: 0.68,
      maxChildSize: 0.86,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: colors.sheetSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.sheetHandle,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.editAvatarAction,
                style: TextStyle(
                  color: colors.title,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 220,
                  height: 220,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.inputFill,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.inputBorder),
                  ),
                  child: ClipOval(
                    child: bytes == null
                        ? const _EmptyPreview()
                        : Image.memory(bytes, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              OutlinedButton.icon(
                onPressed: _isPicking ? null : _pickImage,
                icon: _isPicking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_library_outlined),
                label: Text(l10n.pickFromLibrary),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.accent,
                  side: BorderSide(color: colors.inputBorder),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: bytes == null ? null : _confirm,
                icon: const Icon(Icons.check_rounded),
                label: Text(l10n.saveChanges),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: theme.colorScheme.onPrimary,
                  disabledBackgroundColor:
                      colors.inputBorder.withValues(alpha: 0.7),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ColoredBox(
      color: colors.inputFill,
      child: Center(
        child: Icon(
          Icons.add_photo_alternate_outlined,
          color: colors.placeholderIcon,
          size: 58,
        ),
      ),
    );
  }
}
