import 'package:equatable/equatable.dart';

class AdminPost extends Equatable {
  final String id;
  final String authorId;
  final String authorUsername;
  final String authorDisplayName;
  final String? authorAvatarUrl;
  final String content;
  final int likesCount;
  final int commentsCount;
  final int mediaCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdminPost({
    required this.id,
    required this.authorId,
    required this.authorUsername,
    required this.authorDisplayName,
    this.authorAvatarUrl,
    required this.content,
    required this.likesCount,
    required this.commentsCount,
    required this.mediaCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    authorId,
    authorUsername,
    authorDisplayName,
    authorAvatarUrl,
    content,
    likesCount,
    commentsCount,
    mediaCount,
    createdAt,
    updatedAt,
  ];
}
