import 'package:equatable/equatable.dart';

class ProfilePostPreview extends Equatable {
  final String id;
  final String mediaUrl;

  ProfilePostPreview({required this.id, this.mediaUrl = ''});

  @override
  List<Object?> get props => [id, mediaUrl];
}

class ProfileEntity extends Equatable {
  final String id;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final int postsCount;
  final int friendsCount;
  final List<ProfilePostPreview> posts;

  ProfileEntity({
    required this.id,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.postsCount = 0,
    this.friendsCount = 0,
    this.posts = const [],
  });

  @override
  List<Object?> get props => [
    id,
    username,
    displayName,
    avatarUrl,
    bio,
    postsCount,
    friendsCount,
    posts,
  ];
}
