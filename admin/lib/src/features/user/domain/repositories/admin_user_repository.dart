import '../../../post/domain/entities/admin_post.dart';
import '../entities/admin_user.dart';
import '../entities/admin_user_detail.dart';

abstract class AdminUserRepository {
  Future<List<AdminUser>> getUsers({List<AdminPost>? seedPosts});

  Future<AdminUserDetail> getUserDetail(String userId);
}
