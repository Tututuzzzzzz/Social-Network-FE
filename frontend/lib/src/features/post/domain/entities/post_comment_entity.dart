import 'package:equatable/equatable.dart';

class PostCommentEntity extends Equatable {
  final String id;
  final String? parentCommentId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostCommentEntity({
    required this.id,
    this.parentCommentId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    parentCommentId,
    authorId,
    content,
    createdAt,
    updatedAt,
  ];
}
