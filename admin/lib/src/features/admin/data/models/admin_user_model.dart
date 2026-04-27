import '../../domain/entities/admin_post.dart';
import '../../domain/entities/admin_user.dart';

class AdminUserModel extends AdminUser {
  const AdminUserModel({
    required super.id,
    required super.username,
    required super.displayName,
    super.email,
    super.avatarUrl,
    required super.postsCount,
    super.lastActivityAt,
  });

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
}
