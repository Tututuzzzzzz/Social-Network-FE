import 'package:equatable/equatable.dart';

class ProfilePostPreview extends Equatable {
  final String id;
  final String mediaUrl;
  final String caption;
  final int likesCount;

  const ProfilePostPreview({
    required this.id,
    this.mediaUrl = '',
    this.caption = '',
    this.likesCount = 0,
  });

  @override
  List<Object?> get props => [id, mediaUrl, caption, likesCount];
}

class ProfileEntity extends Equatable {
  final String id;
  final String displayName;
  final String username;
  final String bio;
  final String avatarUrl;
  final int postsCount;
  final int friendsCount;
  final List<ProfilePostPreview> posts;

  const ProfileEntity({
    required this.id,
    this.displayName = '',
    this.username = '',
    this.bio = '',
    this.avatarUrl = '',
    this.postsCount = 0,
    this.friendsCount = 0,
    this.posts = const [],
  });

  @override
  List<Object?> get props => [
    id,
    displayName,
    username,
    bio,
    avatarUrl,
    postsCount,
    friendsCount,
    posts,
  ];
}
