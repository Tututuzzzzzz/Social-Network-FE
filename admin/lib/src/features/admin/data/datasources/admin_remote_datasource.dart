import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../models/admin_dashboard_snapshot_model.dart';
import '../models/admin_post_model.dart';
import '../models/admin_report_model.dart';
import '../models/admin_user_model.dart';

abstract class AdminRemoteDataSource {
  Future<AdminDashboardSnapshotModel> fetchDashboardSnapshot();

  Future<void> deletePost(String postId);

  Future<void> resolveReport(String reportId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient _apiClient;

  const AdminRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AdminDashboardSnapshotModel> fetchDashboardSnapshot() async {
    final posts = await _fetchPosts();
    final users = _deriveUsers(posts);
    final reports = await _fetchReportsIfBackendExists();

    return AdminDashboardSnapshotModel.fromCollections(
      users: users,
      posts: posts,
      reports: reports,
    );
  }

  @override
  Future<void> deletePost(String postId) {
    return _apiClient.delete(ApiConstants.postById(postId));
  }

  @override
  Future<void> resolveReport(String reportId) async {
    return;
  }

  Future<List<AdminPostModel>> _fetchPosts() async {
    final result = await _apiClient.get(
      ApiConstants.postsFeed,
      queryParameters: const {'page': 1, 'limit': 50},
    );

    return _extractPostMaps(result).map(AdminPostModel.fromJson).toList();
  }

  Future<List<AdminReportModel>> _fetchReportsIfBackendExists() async {
    return const [];
  }

  List<AdminUserModel> _deriveUsers(List<AdminPostModel> posts) {
    final counts = <String, int>{};
    final latestPosts = <String, AdminPostModel>{};

    for (final post in posts) {
      if (post.authorId.trim().isEmpty) {
        continue;
      }

      counts[post.authorId] = (counts[post.authorId] ?? 0) + 1;
      final current = latestPosts[post.authorId];
      if (current == null || post.createdAt.isAfter(current.createdAt)) {
        latestPosts[post.authorId] = post;
      }
    }

    final users = latestPosts.entries.map((entry) {
      return AdminUserModel.fromPostAuthor(entry.value, counts[entry.key] ?? 0);
    }).toList();

    users.sort((a, b) {
      final left = a.lastActivityAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = b.lastActivityAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });

    return users;
  }

  List<Map<String, dynamic>> _extractPostMaps(dynamic result) {
    if (result is Map) {
      final map = Map<String, dynamic>.from(result);
      final data = map['data'];
      if (data is Map && data['items'] is List) {
        return _mapsFromList(data['items'] as List);
      }
      if (data is List) {
        return _mapsFromList(data);
      }
      if (map['items'] is List) {
        return _mapsFromList(map['items'] as List);
      }
      if (map['docs'] is List) {
        return _mapsFromList(map['docs'] as List);
      }
    }

    if (result is List) {
      return _mapsFromList(result);
    }

    return const [];
  }

  List<Map<String, dynamic>> _mapsFromList(List<dynamic> values) {
    return values
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
