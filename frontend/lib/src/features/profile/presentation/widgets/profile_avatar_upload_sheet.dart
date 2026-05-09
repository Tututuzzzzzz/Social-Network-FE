import 'dart:typed_data';

import 'package:flutter/material.dart';
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

      if (image == null || !mounted) {
        return;
      }

      final bytes = await image.readAsBytes();
      if (!mounted) return;

      setState(() {
        _selectedBytes = bytes;
        _selectedFileName = image.name.trim().isEmpty
            ? 'avatar.jpg'
            : image.name.trim();
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
    if (bytes == null || fileName == null || fileName.isEmpty) {
      return;
    }

    Navigator.of(
      context,
    ).pop(ProfileAvatarUploadDraft(bytes: bytes, fileName: fileName));
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _selectedBytes;

    return DraggableScrollableSheet(
      expand: false,
      minChildSize: 0.48,
      initialChildSize: 0.68,
      maxChildSize: 0.86,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: const Color(0xFFD8DCE2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tải ảnh đại diện mới',
                style: TextStyle(
                  color: Color(0xFF14221D),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Chọn một ảnh rõ mặt, sau đó xác nhận để cập nhật hồ sơ.',
                style: TextStyle(
                  color: Color(0xFF63706B),
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
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
                    color: const Color(0xFFEAF8F2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFBCEAD8)),
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
                label: Text(bytes == null ? 'Chọn ảnh' : 'Chọn ảnh khác'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF168C68),
                  side: const BorderSide(color: Color(0xFFBCEAD8)),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: bytes == null ? null : _confirm,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Xác nhận cập nhật'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF25A97A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFD7E0DC),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
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
    return const ColoredBox(
      color: Color(0xFFF5FAF7),
      child: Center(
        child: Icon(
          Icons.add_photo_alternate_outlined,
          color: Color(0xFF7BAE9B),
          size: 58,
        ),
      ),
    );
  }
}
