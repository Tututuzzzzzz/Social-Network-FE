import '../repositories/admin_post_repository.dart';

class DeleteAdminPostUseCase {
  final AdminPostRepository _repository;

  const DeleteAdminPostUseCase(this._repository);

  Future<void> call(String postId) {
    return _repository.deletePost(postId);
  }
}
