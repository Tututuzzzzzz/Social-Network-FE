import 'package:equatable/equatable.dart';

import 'admin_post_media.dart';

class AdminPost extends Equatable {
  final String id;
  final String authorId;
  final String authorUsername;
  final String authorDisplayName;
  final String? authorAvatarUrl;
  final String content;
  final int likesCount;
  final int commentsCount;
  final List<String> likeIds;
  final List<AdminPostMedia> media;
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
    this.likeIds = const [],
    this.media = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  int get mediaCount => media.length;

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
    likeIds,
    media,
    createdAt,
    updatedAt,
  ];
}
