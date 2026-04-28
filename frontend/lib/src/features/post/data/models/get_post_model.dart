import '../../domain/entities/post_entity.dart';
import '../../domain/entities/post_comment_entity.dart';
import 'post_media_model.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.authorId,
    super.authorUsername,
    super.authorDisplayName,
    super.authorAvatarUrl,
    super.content,
    super.media,
    super.likes,
    super.comments,
    super.commentsCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorUsername: json['authorUsername'] as String?,
      authorDisplayName: json['authorDisplayName'] as String?,
      authorAvatarUrl: json['authorAvatarUrl'] as String?,
      content: json['content'] as String?,
      media:
          (json['media'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) => PostMediaModel.fromJson(Map<String, dynamic>.from(e)))
              .map((e) => e.toEntity())
              .toList() ??
          [],
      likes:
          (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map(
                (e) => PostCommentEntity(
                  id: e['id'] as String,
                  parentCommentId: e['parentCommentId'] as String?,
                  authorId: e['authorId'] as String,
                  content: e['content'] as String,
                  createdAt: DateTime.parse(e['createdAt'] as String),
                  updatedAt: DateTime.parse(e['updatedAt'] as String),
                ),
              )
              .toList() ??
          [],
      commentsCount: json['commentsCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static List<PostModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      authorId: entity.authorId,
      authorUsername: entity.authorUsername,
      authorDisplayName: entity.authorDisplayName,
      authorAvatarUrl: entity.authorAvatarUrl,
      content: entity.content,
      media: entity.media,
      likes: entity.likes,
      comments: entity.comments,
      commentsCount: entity.commentsCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<PostModel> fromMapList(List<Map<String, dynamic>> mapList) {
    return mapList.map((map) => PostModel.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorUsername': authorUsername,
      'authorDisplayName': authorDisplayName,
      'authorAvatarUrl': authorAvatarUrl,
      'content': content,
      'media': media.map((e) => PostMediaModel.fromEntity(e).toJson()).toList(),
      'likes': likes,
      'comments': comments
          .map(
            (e) => {
              'id': e.id,
              'parentCommentId': e.parentCommentId,
              'authorId': e.authorId,
              'content': e.content,
              'createdAt': e.createdAt.toIso8601String(),
              'updatedAt': e.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static List<Map<String, dynamic>> toJsonList(List<PostModel> posts) {
    return posts.map((post) => post.toJson()).toList();
  }
}
