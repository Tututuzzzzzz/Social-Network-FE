import '../entities/admin_user_detail.dart';
import '../repositories/admin_user_repository.dart';

class GetAdminUserDetailUseCase {
  final AdminUserRepository _repository;

  const GetAdminUserDetailUseCase(this._repository);

  Future<AdminUserDetail> call(String userId) {
    return _repository.getUserDetail(userId);
  }
}
