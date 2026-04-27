import '../../domain/entities/admin_post.dart';

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
    required super.mediaCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AdminPostModel.fromJson(Map<String, dynamic> json) {
    final author = json['authorId'];
    final authorMap = author is Map ? Map<String, dynamic>.from(author) : null;
    final media = json['media'] is List ? json['media'] as List : const [];
    final likes = json['likes'] is List ? json['likes'] as List : const [];
    final comments = json['comments'] is List
        ? json['comments'] as List
        : const [];
    final authorId = authorMap == null
        ? (author ?? '').toString()
        : (authorMap['_id'] ?? authorMap['id'] ?? '').toString();
    final username = authorMap == null
        ? 'unknown'
        : (authorMap['username'] ?? 'unknown').toString();
    final displayName = authorMap == null
        ? username
        : (authorMap['displayName'] ?? authorMap['fullName'] ?? username)
              .toString();

    return AdminPostModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      authorId: authorId,
      authorUsername: username,
      authorDisplayName: displayName,
      authorAvatarUrl: authorMap == null
          ? null
          : (authorMap['avatarUrl'] ?? authorMap['avatar'])?.toString(),
      content: (json['content'] ?? '').toString(),
      likesCount: (json['likesCount'] as num?)?.toInt() ?? likes.length,
      commentsCount:
          (json['commentsCount'] as num?)?.toInt() ?? comments.length,
      mediaCount: media.length,
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
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
