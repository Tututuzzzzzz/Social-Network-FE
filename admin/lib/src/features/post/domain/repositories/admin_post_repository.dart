import '../entities/admin_post.dart';
import '../entities/admin_post_detail.dart';

abstract class AdminPostRepository {
  Future<List<AdminPost>> getPosts();

  Future<AdminPostDetail> getPostDetail(String postId);

  Future<void> hidePost(String postId);

  Future<void> restorePost(String postId);

  Future<void> deletePost(String postId);
}
