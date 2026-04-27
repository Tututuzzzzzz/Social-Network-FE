import '../repositories/admin_repository.dart';

class DeleteAdminPostUseCase {
  final AdminRepository _repository;

  const DeleteAdminPostUseCase(this._repository);

  Future<void> call(String postId) {
    return _repository.deletePost(postId);
  }
}
