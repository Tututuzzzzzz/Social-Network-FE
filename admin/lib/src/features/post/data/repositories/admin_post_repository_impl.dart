import '../../domain/entities/admin_post.dart';
import '../../domain/entities/admin_post_detail.dart';
import '../../domain/repositories/admin_post_repository.dart';
import '../datasources/admin_post_remote_datasource.dart';

class AdminPostRepositoryImpl implements AdminPostRepository {
  final AdminPostRemoteDataSource _remoteDataSource;

  const AdminPostRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AdminPost>> getPosts() {
    return _remoteDataSource.fetchPosts();
  }

  @override
  Future<AdminPostDetail> getPostDetail(String postId) {
    return _remoteDataSource.fetchPostDetail(postId);
  }

  @override
  Future<void> deletePost(String postId) {
    return _remoteDataSource.deletePost(postId);
  }
}
