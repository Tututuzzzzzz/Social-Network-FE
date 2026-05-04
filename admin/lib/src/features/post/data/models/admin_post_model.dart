import '../../domain/entities/admin_post.dart';
import '../../domain/entities/admin_post_media.dart';
import 'admin_post_media_model.dart';

class AdminPostModel extends AdminPost {
  const AdminPostModel({
    required super.id,
    required super.authorId,
    required super.authorUsername,
    required super.authorDisplayName,
    super.authorAvatarUrl,
    required super.content,
    required super.likesCount,
    required super.commentsCount,
    super.likeIds,
    super.media,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AdminPostModel.fromJson(Map<String, dynamic> json) {
    final root = _root(json);
    final authorMap = _authorMap(root);
    final media = _mediaValues(root);
    final likes = root['likes'] is List ? root['likes'] as List : const [];
    final comments = root['comments'] is List
        ? root['comments'] as List
        : const [];
    final authorId = _firstText([
      _idFromValue(root['authorId']),
      _idFromValue(root['author']),
      _idFromValue(root['userId']),
      _idFromValue(root['user']),
      _idFromValue(root['owner']),
      _idFromValue(root['createdBy']),
      _idFromValue(authorMap),
    ]);
    final username = _firstText([
      root['authorUsername'],
      root['username'],
      authorMap?['username'],
      authorMap?['userName'],
      authorId,
      'unknown',
    ]);
    final displayName = _firstText([
      root['authorDisplayName'],
      root['displayName'],
      root['fullName'],
      authorMap?['displayName'],
      authorMap?['fullName'],
      authorMap?['name'],
      username,
    ]);

    return AdminPostModel(
      id: _firstText([root['_id'], root['id']]),
      authorId: authorId,
      authorUsername: username,
      authorDisplayName: displayName,
      authorAvatarUrl: _nullableText([
        root['authorAvatarUrl'],
        root['avatarUrl'],
        root['avatar'],
        authorMap?['avatarUrl'],
        authorMap?['avatar'],
      ]),
      content: _firstText([root['content'], root['caption'], root['text']]),
      likesCount: (root['likesCount'] as num?)?.toInt() ?? likes.length,
      commentsCount:
          (root['commentsCount'] as num?)?.toInt() ?? comments.length,
      likeIds: likes.map((item) => item.toString()).toList(),
      media: _media(media),
      createdAt: _date(root['createdAt']),
      updatedAt: _date(root['updatedAt']),
    );
  }

  static Map<String, dynamic> _root(Map<String, dynamic> json) {
    for (final key in ['post', 'item', 'doc']) {
      final value = json[key];
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }
    return json;
  }

  static Map<String, dynamic>? _authorMap(Map<String, dynamic> json) {
    for (final key in [
      'authorId',
      'author',
      'userId',
      'user',
      'owner',
      'createdBy',
    ]) {
      final value = json[key];
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }
    return null;
  }

  static String _idFromValue(dynamic value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      return _firstText([map['_id'], map['id']]);
    }
    return _firstText([value]);
  }

  static String _firstText(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  static String? _nullableText(List<dynamic> values) {
    final text = _firstText(values);
    return text.isEmpty ? null : text;
  }

  static List<dynamic> _mediaValues(Map<String, dynamic> json) {
    for (final key in [
      'media',
      'medias',
      'attachments',
      'files',
      'images',
      'imageUrls',
      'mediaUrls',
      'urls',
    ]) {
      final value = json[key];
      if (value is List) {
        return value;
      }
    }

    final single = _nullableText([
      json['mediaUrl'],
      json['imageUrl'],
      json['url'],
      json['publicUrl'],
    ]);
    return single == null ? const [] : [single];
  }

  static List<AdminPostMedia> _media(List<dynamic> values) {
    return values
        .map((item) {
          if (item is Map) {
            return AdminPostMediaModel.fromJson(
              Map<String, dynamic>.from(item),
            );
          }
          final url = item.toString().trim();
          if (url.isEmpty) {
            return null;
          }
          return AdminPostMediaModel.fromJson({'mediaUrl': url});
        })
        .whereType<AdminPostMediaModel>()
        .toList();
  }

  static DateTime _date(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
