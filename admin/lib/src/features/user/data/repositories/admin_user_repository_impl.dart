import '../../../post/domain/entities/admin_post.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/admin_user_detail.dart';
import '../../domain/repositories/admin_user_repository.dart';
import '../datasources/admin_user_remote_datasource.dart';

class AdminUserRepositoryImpl implements AdminUserRepository {
  final AdminUserRemoteDataSource _remoteDataSource;

  const AdminUserRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AdminUser>> getUsers({List<AdminPost>? seedPosts}) {
    return _remoteDataSource.fetchUsers(seedPosts: seedPosts);
  }

  @override
  Future<AdminUserDetail> getUserDetail(String userId) {
    return _remoteDataSource.fetchUserDetail(userId);
  }
}
