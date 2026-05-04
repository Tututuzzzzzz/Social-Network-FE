import 'package:equatable/equatable.dart';

class PostCommentEntity extends Equatable {
  final String id;
  final String? parentCommentId;
  final String authorId;
  final String? authorUsername;
  final String? authorDisplayName;
  final String? authorAvatarUrl;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostCommentEntity({
    required this.id,
    this.parentCommentId,
    required this.authorId,
    this.authorUsername,
    this.authorDisplayName,
    this.authorAvatarUrl,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    parentCommentId,
    authorId,
    authorUsername,
    authorDisplayName,
    authorAvatarUrl,
    content,
    createdAt,
    updatedAt,
  ];
}
