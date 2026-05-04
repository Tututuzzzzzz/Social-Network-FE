import '../../../post/domain/entities/admin_post.dart';
import '../../domain/entities/admin_user.dart';

class AdminUserModel extends AdminUser {
  const AdminUserModel({
    required super.id,
    required super.username,
    required super.displayName,
    super.email,
    super.avatarUrl,
    required super.postsCount,
    super.friendsCount,
    super.bio,
    super.phone,
    super.lastActivityAt,
    super.createdAt,
  });

  factory AdminUserModel.fromProfileJson({
    required Map<String, dynamic> userJson,
    required Map<String, dynamic> statsJson,
  }) {
    final postsCount = (statsJson['postsCount'] as num?)?.toInt() ?? 0;
    final createdAt = _date(userJson['createdAt']);

    return AdminUserModel(
      id: (userJson['_id'] ?? userJson['id'] ?? '').toString(),
      username: (userJson['username'] ?? 'unknown').toString(),
      displayName:
          (userJson['displayName'] ?? userJson['username'] ?? 'unknown')
              .toString(),
      email: userJson['email']?.toString(),
      avatarUrl: (userJson['avatarUrl'] ?? userJson['avatar'])?.toString(),
      postsCount: postsCount,
      friendsCount: (statsJson['friendsCount'] as num?)?.toInt(),
      bio: userJson['bio']?.toString(),
      phone: userJson['phone']?.toString(),
      lastActivityAt: createdAt,
      createdAt: createdAt,
    );
  }

  factory AdminUserModel.fromPostAuthor(AdminPost post, int postsCount) {
    return AdminUserModel(
      id: post.authorId,
      username: post.authorUsername,
      displayName: post.authorDisplayName,
      avatarUrl: post.authorAvatarUrl,
      postsCount: postsCount,
      lastActivityAt: post.createdAt,
    );
  }

  static DateTime? _date(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
