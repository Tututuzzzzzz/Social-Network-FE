import 'package:equatable/equatable.dart';

class AdminPostComment extends Equatable {
  final String id;
  final String? parentCommentId;
  final String authorId;
  final String authorUsername;
  final String authorDisplayName;
  final String? authorAvatarUrl;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AdminPostComment> children;

  const AdminPostComment({
    required this.id,
    this.parentCommentId,
    required this.authorId,
    required this.authorUsername,
    required this.authorDisplayName,
    this.authorAvatarUrl,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.children = const [],
  });

  int get descendantsCount {
    return children.fold<int>(
      children.length,
      (total, child) => total + child.descendantsCount,
    );
  }

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
    children,
  ];
}
