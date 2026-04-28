import 'package:equatable/equatable.dart';

import 'post_comment_entity.dart';
import 'post_media_entity.dart';

class PostEntity extends Equatable {
  final String id;
  final String authorId;
  final String? authorUsername;
  final String? authorDisplayName;
  final String? authorAvatarUrl;
  final String? content;
  final List<PostMediaEntity> media;
  final List<String> likes;
  final List<PostCommentEntity> comments;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostEntity({
    required this.id,
    required this.authorId,
    this.authorUsername,
    this.authorDisplayName,
    this.authorAvatarUrl,
    this.content,
    this.media = const [],
    this.likes = const [],
    this.comments = const [],
    this.commentsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  PostEntity copyWith({
    String? authorId,
    String? authorUsername,
    String? authorDisplayName,
    String? authorAvatarUrl,
    String? content,
    List<PostMediaEntity>? media,
    List<String>? likes,
    List<PostCommentEntity>? comments,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostEntity(
      id: id,
      authorId: authorId ?? this.authorId,
      authorUsername: authorUsername ?? this.authorUsername,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      content: content ?? this.content,
      media: media ?? this.media,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    authorId,
    authorUsername,
    authorDisplayName,
    authorAvatarUrl,
    content,
    media,
    likes,
    comments,
    commentsCount,
    createdAt,
    updatedAt,
  ];
}
