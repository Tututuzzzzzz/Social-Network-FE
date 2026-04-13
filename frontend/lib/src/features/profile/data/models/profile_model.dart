import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    super.displayName,
    super.username,
    super.bio,
    super.avatarUrl,
    super.postsCount,
    super.friendsCount,
    super.posts,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final postsRaw = json['posts'];
    final posts = postsRaw is List
        ? postsRaw
              .whereType<Map>()
              .map(
                (item) => ProfilePostPreview(
                  id: item['id']?.toString() ?? '',
                  mediaUrl: item['mediaUrl']?.toString() ?? '',
                  caption: item['caption']?.toString() ?? '',
                  likesCount: (item['likesCount'] as num?)?.toInt() ?? 0,
                ),
              )
              .toList()
        : const <ProfilePostPreview>[];

    return ProfileModel(
      id: json['id']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
      friendsCount: (json['friendsCount'] as num?)?.toInt() ?? 0,
      posts: posts,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'username': username,
    'bio': bio,
    'avatarUrl': avatarUrl,
    'postsCount': postsCount,
    'friendsCount': friendsCount,
    'posts': posts
        .map(
          (item) => {
            'id': item.id,
            'mediaUrl': item.mediaUrl,
            'caption': item.caption,
            'likesCount': item.likesCount,
          },
        )
        .toList(),
  };
}
