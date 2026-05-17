import '../../../post/domain/repositories/admin_post_repository.dart';
import '../../../report/domain/entities/admin_report.dart';
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
    final reports = await _getReports(posts.map((post) => post.id).toList());

    return AdminDashboardSnapshotModel.fromCollections(
      users: users,
      posts: posts,
      reports: reports,
    );
  }

  Future<List<AdminReport>> _getReports(List<String> postIds) async {
    final pendingReports = await _reportRepository.getReports();
    final reportsByPost = await Future.wait(
      postIds
          .where((postId) => postId.trim().isNotEmpty)
          .map(_getReportsByPostSafely),
    );

    final reportsById = {
      for (final report in pendingReports) report.id: report,
    };

    for (final reports in reportsByPost) {
      for (final report in reports) {
        reportsById[report.id] = report;
      }
    }

    return reportsById.values.toList();
  }

  Future<List<AdminReport>> _getReportsByPostSafely(String postId) async {
    try {
      return _reportRepository.getReportsByPost(postId);
    } catch (_) {
      return const [];
    }
  }
}
