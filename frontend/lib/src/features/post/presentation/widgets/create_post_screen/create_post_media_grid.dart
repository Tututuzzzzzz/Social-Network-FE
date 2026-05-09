import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostMediaGrid extends StatelessWidget {
  const CreatePostMediaGrid({
    super.key,
    required this.images,
    required this.onEditImage,
  });

  final List<XFile> images;
  final ValueChanged<int> onEditImage;

  @override
  Widget build(BuildContext context) {
    final imageCount = images.length;
    if (imageCount == 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (imageCount == 1) {
          return AspectRatio(
            aspectRatio: 1,
            child: _buildImageTile(0),
          );
        }

        if (imageCount == 2) {
          return Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 0.78,
                  child: _buildImageTile(0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 0.78,
                  child: _buildImageTile(1),
                ),
              ),
            ],
          );
        }

        final height = (width * 0.82).clamp(260.0, 420.0).toDouble();

        return SizedBox(
          height: height,
          child: Row(
            children: [
              Expanded(
                flex: 52,
                child: _buildImageTile(0),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 48,
                child: Column(
                  children: [
                    Expanded(child: _buildImageTile(1)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildImageTile(
                        2,
                        overflowCount: imageCount > 3 ? imageCount - 3 : 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageTile(int index, {int overflowCount = 0}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _PickedImage(image: images[index]),
          if (overflowCount > 0)
            Container(
              color: Colors.black.withValues(alpha: 0.36),
              alignment: Alignment.center,
              child: Text(
                '+$overflowCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          Positioned(
            top: 9,
            right: 9,
            child: _ImageEditBadge(onTap: () => onEditImage(index)),
          ),
        ],
      ),
    );
  }
}

class _PickedImage extends StatelessWidget {
  const _PickedImage({required this.image});

  final XFile image;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(image.path, fit: BoxFit.cover);
    }

    return Image.file(File(image.path), fit: BoxFit.cover);
  }
}

class _ImageEditBadge extends StatelessWidget {
  const _ImageEditBadge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF9FA4AA).withValues(alpha: 0.86),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(Icons.edit_outlined, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
