import 'package:flutter/material.dart';

import '../../../../core/utils/url_normalizer.dart';
import '../../../post/domain/entities/post_entity.dart';
import 'profile_empty_state.dart';

class ProfilePhotosTab extends StatelessWidget {
  const ProfilePhotosTab({super.key, required this.posts, this.onRefresh});

  final List<PostEntity> posts;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final photos = _extractPhotos(posts);

    if (photos.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.14),
            const ProfileEmptyState(
              icon: Icons.photo_library_outlined,
              title: 'Chưa có ảnh',
              message: 'Ảnh từ các bài viết của hồ sơ này sẽ nằm ở đây.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: photos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 7,
          mainAxisSpacing: 7,
        ),
        itemBuilder: (context, index) {
          final photo = photos[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              photo.url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const ColoredBox(
                  color: Color(0xFFE9EFEC),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              },
              errorBuilder: (_, _, _) {
                return const ColoredBox(
                  color: Color(0xFFE9EFEC),
                  child: Icon(Icons.broken_image_outlined, color: Colors.grey),
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<_ProfilePhoto> _extractPhotos(List<PostEntity> posts) {
    final photos = <_ProfilePhoto>[];

    for (final post in posts) {
      for (final media in post.media) {
        final mediaUrl = media.mediaUrl?.trim();
        if (mediaUrl != null && mediaUrl.isNotEmpty) {
          photos.add(
            _ProfilePhoto(postId: post.id, url: mediaUrl.normalizeClientUrl()),
          );
          continue;
        }

        final objectKey = media.objectKey.trim();
        if (objectKey.startsWith('http://') ||
            objectKey.startsWith('https://')) {
          photos.add(
            _ProfilePhoto(postId: post.id, url: objectKey.normalizeClientUrl()),
          );
        }
      }
    }

    return photos;
  }
}

class _ProfilePhoto {
  const _ProfilePhoto({required this.postId, required this.url});

  final String postId;
  final String url;
}
