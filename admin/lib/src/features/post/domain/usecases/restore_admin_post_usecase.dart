import '../repositories/admin_post_repository.dart';

class RestoreAdminPostUseCase {
  final AdminPostRepository _repository;

  const RestoreAdminPostUseCase(this._repository);

  Future<void> call(String postId) {
    return _repository.restorePost(postId);
  }
}
