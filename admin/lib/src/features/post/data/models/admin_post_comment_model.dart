import '../../domain/entities/admin_post_comment.dart';

class AdminPostCommentModel extends AdminPostComment {
  const AdminPostCommentModel({
    required super.id,
    super.parentCommentId,
    required super.authorId,
    required super.authorUsername,
    required super.authorDisplayName,
    super.authorAvatarUrl,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
    super.children,
  });

  factory AdminPostCommentModel.fromJson(Map<String, dynamic> json) {
    final author = json['authorId'];
    final authorMap = author is Map ? Map<String, dynamic>.from(author) : null;
    final authorId = authorMap == null
        ? (author ?? '').toString()
        : (authorMap['_id'] ?? authorMap['id'] ?? '').toString();
    final username = authorMap == null
        ? shortId(authorId)
        : (authorMap['username'] ?? 'unknown').toString();
    final displayName = authorMap == null
        ? username
        : (authorMap['displayName'] ?? authorMap['fullName'] ?? username)
              .toString();

    return AdminPostCommentModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      parentCommentId: json['parentCommentId']?.toString(),
      authorId: authorId,
      authorUsername: username,
      authorDisplayName: displayName,
      authorAvatarUrl: authorMap == null
          ? null
          : (authorMap['avatarUrl'] ?? authorMap['avatar'])?.toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
      children: _children(json['children']),
    );
  }

  static List<AdminPostComment> _children(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) =>
              AdminPostCommentModel.fromJson(Map<String, dynamic>.from(item)),
        )
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

  static String shortId(String id) {
    if (id.length <= 10) {
      return id;
    }
    return '${id.substring(0, 6)}...${id.substring(id.length - 4)}';
  }
}
