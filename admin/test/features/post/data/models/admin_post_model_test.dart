import 'package:admin/src/features/post/data/models/admin_post_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses nested post author and media url list', () {
    final post = AdminPostModel.fromJson({
      'post': {
        '_id': 'post-1',
        'author': {
          '_id': 'user-1',
          'username': 'alice',
          'displayName': 'Alice Nguyen',
          'avatar': '/uploads/avatar.png',
        },
        'content': 'hello',
        'mediaUrls': ['https://cdn.example.com/photo.jpg'],
        'likes': ['user-2'],
        'commentsCount': 3,
        'createdAt': '2026-05-03T16:30:00.000Z',
        'updatedAt': '2026-05-03T16:31:00.000Z',
      },
    });

    expect(post.id, 'post-1');
    expect(post.authorId, 'user-1');
    expect(post.authorUsername, 'alice');
    expect(post.authorDisplayName, 'Alice Nguyen');
    expect(post.mediaCount, 1);
    expect(post.media.first.mediaUrl, 'https://cdn.example.com/photo.jpg');
    expect(post.media.first.isImage, isTrue);
  });

  test('parses direct author fields and public media url', () {
    final post = AdminPostModel.fromJson({
      '_id': 'post-2',
      'authorId': 'user-2',
      'authorUsername': 'bob',
      'authorDisplayName': 'Bob Tran',
      'authorAvatarUrl': 'https://cdn.example.com/bob.png',
      'media': [
        {'publicUrl': 'https://cdn.example.com/post.webp'},
      ],
      'createdAt': '2026-05-03T16:30:00.000Z',
      'updatedAt': '2026-05-03T16:31:00.000Z',
    });

    expect(post.authorUsername, 'bob');
    expect(post.authorDisplayName, 'Bob Tran');
    expect(post.authorAvatarUrl, 'https://cdn.example.com/bob.png');
    expect(post.mediaCount, 1);
    expect(post.media.first.mediaUrl, 'https://cdn.example.com/post.webp');
    expect(post.media.first.mimeType, 'image/webp');
  });
}
