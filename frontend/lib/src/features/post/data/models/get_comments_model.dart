import '../../domain/entities/post_comment_entity.dart';
import '../../domain/entities/post_comments_entity.dart';

class GetCommentsModel extends PostCommentsEntity {
  const GetCommentsModel({super.comments, super.commentsCount});

  factory GetCommentsModel.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    final data = dataRaw is Map ? Map<String, dynamic>.from(dataRaw) : json;

    final flatRaw = data['flatComments'];
    final source = flatRaw is List
        ? flatRaw
        : (data['comments'] as List? ?? const []);

    final comments = source
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(_commentFromJson)
        .toList();

    return GetCommentsModel(
      comments: comments,
      commentsCount:
          (data['commentsCount'] as num?)?.toInt() ?? comments.length,
    );
  }
}

PostCommentEntity _commentFromJson(Map<String, dynamic> json) {
  final authorRaw = json['authorId'];
  final authorMap = authorRaw is Map
      ? Map<String, dynamic>.from(authorRaw)
      : null;
  final authorId = authorMap != null
      ? (authorMap['_id'] ?? authorMap['id'] ?? '').toString()
      : authorRaw?.toString() ?? '';

  return PostCommentEntity(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    parentCommentId: json['parentCommentId']?.toString(),
    authorId: authorId,
    authorUsername: _firstNonEmpty([
      json['authorUsername'],
      authorMap?['username'],
    ]),
    authorDisplayName: _firstNonEmpty([
      json['authorDisplayName'],
      authorMap?['displayName'],
      authorMap?['fullName'],
    ]),
    authorAvatarUrl: _firstNonEmpty([
      json['authorAvatarUrl'],
      json['avatarUrl'],
      authorMap?['avatarUrl'],
      authorMap?['avatar'],
    ]),
    content: json['content']?.toString() ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
        DateTime.now(),
  );
}

String? _firstNonEmpty(List<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }

  return null;
}
