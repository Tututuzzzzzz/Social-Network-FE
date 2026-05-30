import 'package:flutter/material.dart';
import 'package:frontend/src/core/theme/app_colors.dart';
import 'package:frontend/src/core/testing/test_keys.dart';

import 'create_post_actions.dart';

class CreatePostBottomTools extends StatelessWidget {
  const CreatePostBottomTools({
    super.key,
    required this.isPickingImages,
    required this.onPickFromGallery,
    required this.onPickFromCamera,
    required this.onTemplate,
  });

  final bool isPickingImages;
  final VoidCallback onPickFromGallery;
  final VoidCallback onPickFromCamera;
  final VoidCallback onTemplate;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SafeArea(
      top: false,
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: colors.sheetSurface,
          border: Border(top: BorderSide(color: colors.navBorder)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            CreatePostToolbarIconButton(
              buttonKey: TestKeys.createPostLibraryButton,
              icon: Icons.image_outlined,
              onTap: isPickingImages ? null : onPickFromGallery,
            ),
            const SizedBox(width: 26),
            CreatePostToolbarIconButton(
              buttonKey: TestKeys.createPostCameraButton,
              icon: Icons.photo_camera_outlined,
              onTap: isPickingImages ? null : onPickFromCamera,
            ),
            const SizedBox(width: 26),
            CreatePostToolbarIconButton(
              buttonKey: TestKeys.createPostTemplateButton,
              icon: Icons.dashboard_outlined,
              onTap: onTemplate,
            ),
          ],
        ),
      ),
    );
  }
}
