import '../entities/admin_post.dart';
import '../repositories/admin_post_repository.dart';

class GetAdminPostsUseCase {
  final AdminPostRepository _repository;

  const GetAdminPostsUseCase(this._repository);

  Future<List<AdminPost>> call() {
    return _repository.getPosts();
  }
}
