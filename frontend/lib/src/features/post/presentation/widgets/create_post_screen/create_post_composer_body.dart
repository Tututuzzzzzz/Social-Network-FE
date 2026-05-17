import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:frontend/src/core/l10n/l10n.dart';
import 'create_post_actions.dart';
import 'create_post_media_grid.dart';
import 'create_post_theme.dart';
import 'package:frontend/src/core/testing/test_keys.dart';

class CreatePostComposerBody extends StatelessWidget {
  const CreatePostComposerBody({
    super.key,
    required this.captionController,
    required this.selectedImages,
    required this.showEmptyActions,
    required this.isPickingImages,
    required this.onCaptionChanged,
    required this.onPickFromGallery,
    required this.onPickFromCamera,
    required this.onTemplate,
    required this.onEditImage,
  });

  final TextEditingController captionController;
  final List<XFile> selectedImages;
  final bool showEmptyActions;
  final bool isPickingImages;
  final ValueChanged<String> onCaptionChanged;
  final VoidCallback onPickFromGallery;
  final VoidCallback onPickFromCamera;
  final VoidCallback onTemplate;
  final ValueChanged<int> onEditImage;

  @override
  Widget build(BuildContext context) {
    final hasImages = selectedImages.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final emptyActionGap = (constraints.maxHeight * 0.30)
            .clamp(170.0, 250.0)
            .toDouble();

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  TextField(
                    key: TestKeys.createPostCaptionField,
                    controller: captionController,
                    minLines: 1,
                    maxLines: null,
                    maxLength: 1500,
                    cursorColor: CreatePostTheme.accentColor,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    onChanged: onCaptionChanged,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 21,
                      fontWeight: FontWeight.w400,
                      height: 1.42,
                      letterSpacing: 0,
                    ),
                    decoration: InputDecoration(
                      hintText: context.l10n.captionHint,
                      hintStyle: TextStyle(
                        color: isDark
                            ? const Color(0xFFB9BEC6)
                            : Colors.black54,
                        fontSize: 21,
                        fontWeight: FontWeight.w400,
                        height: 1.42,
                        letterSpacing: 0,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      counterText: '',
                      isCollapsed: true,
                    ),
                  ),
                  if (hasImages) ...[
                    const SizedBox(height: 22),
                    CreatePostMediaGrid(
                      images: selectedImages,
                      onEditImage: onEditImage,
                    ),
                  ],
                  if (showEmptyActions) ...[
                    SizedBox(height: emptyActionGap),
                    _EmptyActions(
                      isPickingImages: isPickingImages,
                      onPickFromGallery: onPickFromGallery,
                      onPickFromCamera: onPickFromCamera,
                      onTemplate: onTemplate,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyActions extends StatelessWidget {
  const _EmptyActions({
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
    return Row(
      children: [
        Expanded(
          child: CreatePostActionButton(
            icon: Icons.image_outlined,
            label: context.l10n.libraryLabel,
            onTap: isPickingImages ? null : onPickFromGallery,
          ),
        ),
        Expanded(
          child: CreatePostActionButton(
            icon: Icons.photo_camera_outlined,
            label: context.l10n.cameraLabel,
            onTap: isPickingImages ? null : onPickFromCamera,
          ),
        ),
        Expanded(
          child: CreatePostActionButton(
            icon: Icons.dashboard_outlined,
            label: context.l10n.templateLabel,
            onTap: onTemplate,
          ),
        ),
      ],
    );
  }
}
