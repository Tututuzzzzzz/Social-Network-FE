import '../repositories/admin_post_repository.dart';

class HideAdminPostUseCase {
  final AdminPostRepository _repository;

  const HideAdminPostUseCase(this._repository);

  Future<void> call(String postId) {
    return _repository.hidePost(postId);
  }
}
