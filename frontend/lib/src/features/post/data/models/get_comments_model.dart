import '../../domain/entities/post_comment_entity.dart';
import '../../domain/entities/post_comments_entity.dart';

class GetCommentsModel extends PostCommentsEntity {
  const GetCommentsModel({super.comments, super.commentsCount});

  factory GetCommentsModel.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    final data = dataRaw is Map
        ? Map<String, dynamic>.from(dataRaw)
        : json;

    final flatRaw = data['flatComments'];
    final source = flatRaw is List ? flatRaw : (data['comments'] as List? ?? const []);

    final comments = source
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(_commentFromJson)
        .toList();

    return GetCommentsModel(
      comments: comments,
      commentsCount: (data['commentsCount'] as num?)?.toInt() ?? comments.length,
    );
  }
}

PostCommentEntity _commentFromJson(Map<String, dynamic> json) {
  final authorRaw = json['authorId'];
  final authorId = authorRaw is Map
      ? (authorRaw['_id'] ?? authorRaw['id'] ?? '').toString()
      : authorRaw?.toString() ?? '';

  return PostCommentEntity(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    parentCommentId: json['parentCommentId']?.toString(),
    authorId: authorId,
    authorUsername: authorRaw is Map ? authorRaw['username']?.toString() : null,
    authorDisplayName: authorRaw is Map
        ? ((authorRaw['displayName'] ?? authorRaw['fullName'])?.toString())
        : null,
    authorAvatarUrl: authorRaw is Map ? authorRaw['avatarUrl']?.toString() : null,
    content: json['content']?.toString() ?? '',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
  );
}
