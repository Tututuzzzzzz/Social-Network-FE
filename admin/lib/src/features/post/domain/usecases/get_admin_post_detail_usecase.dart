import '../entities/admin_post_detail.dart';
import '../repositories/admin_post_repository.dart';

class GetAdminPostDetailUseCase {
  final AdminPostRepository _repository;

  const GetAdminPostDetailUseCase(this._repository);

  Future<AdminPostDetail> call(String postId) {
    return _repository.getPostDetail(postId);
  }
}
