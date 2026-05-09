import 'package:flutter/material.dart';

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
    return SafeArea(
      top: false,
      child: Container(
        height: 78,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E4E8))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            CreatePostToolbarIconButton(
              icon: Icons.image_outlined,
              onTap: isPickingImages ? null : onPickFromGallery,
            ),
            const SizedBox(width: 26),
            CreatePostToolbarIconButton(
              icon: Icons.photo_camera_outlined,
              onTap: isPickingImages ? null : onPickFromCamera,
            ),
            const SizedBox(width: 26),
            CreatePostToolbarIconButton(
              icon: Icons.dashboard_outlined,
              onTap: onTemplate,
            ),
          ],
        ),
      ),
    );
  }
}
