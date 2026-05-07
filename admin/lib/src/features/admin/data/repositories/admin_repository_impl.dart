import '../../../post/domain/repositories/admin_post_repository.dart';
import '../../../report/domain/repositories/admin_report_repository.dart';
import '../../../user/domain/repositories/admin_user_repository.dart';
import '../models/admin_dashboard_snapshot_model.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminUserRepository _userRepository;
  final AdminPostRepository _postRepository;
  final AdminReportRepository _reportRepository;

  const AdminRepositoryImpl(
    this._userRepository,
    this._postRepository,
    this._reportRepository,
  );

  @override
  Future<AdminDashboardSnapshotModel> getDashboardSnapshot() async {
    final posts = await _postRepository.getPosts();
    final users = await _userRepository.getUsers(seedPosts: posts);
    final reports = await _reportRepository.getReports();

    return AdminDashboardSnapshotModel.fromCollections(
      users: users,
      posts: posts,
      reports: reports,
    );
  }
}
