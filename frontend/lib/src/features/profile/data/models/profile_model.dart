import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    super.username,
    super.displayName,
    super.bio,
    super.avatarUrl,
    super.postsCount,
    super.friendsCount,
    super.posts,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      displayName: json['displayName'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
      friendsCount: (json['friendsCount'] as num?)?.toInt() ?? 0,
      posts: (json['posts'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (e) => ProfilePostPreview(
              id: e['id'] as String,
              mediaUrl: e['mediaUrl'] as String? ?? '',
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'postsCount': postsCount,
      'friendsCount': friendsCount,
      'posts': posts.map((e) => {'id': e.id, 'mediaUrl': e.mediaUrl}).toList(),
    };
  }
}
