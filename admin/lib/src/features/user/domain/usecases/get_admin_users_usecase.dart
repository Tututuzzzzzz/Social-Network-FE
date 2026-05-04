import '../../../post/domain/entities/admin_post.dart';
import '../entities/admin_user.dart';
import '../repositories/admin_user_repository.dart';

class GetAdminUsersUseCase {
  final AdminUserRepository _repository;

  const GetAdminUsersUseCase(this._repository);

  Future<List<AdminUser>> call({List<AdminPost>? seedPosts}) {
    return _repository.getUsers(seedPosts: seedPosts);
  }
}
