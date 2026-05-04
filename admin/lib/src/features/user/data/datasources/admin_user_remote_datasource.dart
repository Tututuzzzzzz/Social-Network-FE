import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../post/data/models/admin_post_model.dart';
import '../../../post/domain/entities/admin_post.dart';
import '../models/admin_user_detail_model.dart';
import '../models/admin_user_model.dart';

abstract class AdminUserRemoteDataSource {
  Future<List<AdminUserModel>> fetchUsers({List<AdminPost>? seedPosts});

  Future<AdminUserDetailModel> fetchUserDetail(String userId);
}

class AdminUserRemoteDataSourceImpl implements AdminUserRemoteDataSource {
  final ApiClient _apiClient;

  const AdminUserRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<AdminUserModel>> fetchUsers({List<AdminPost>? seedPosts}) async {
    final posts = seedPosts ?? await _fetchPosts();
    return _deriveUsers(posts);
  }

  @override
  Future<AdminUserDetailModel> fetchUserDetail(String userId) async {
    final profile = await _apiClient.get(ApiConstants.userProfile(userId));
    final posts = await _apiClient.get(
      ApiConstants.userPosts(userId),
      queryParameters: const {'page': 1, 'limit': 20},
    );

    return AdminUserDetailModel.fromResponses(
      profileResponse: profile,
      postsResponse: posts,
    );
  }

  Future<List<AdminPost>> _fetchPosts() async {
    final result = await _apiClient.get(
      ApiConstants.postsFeed,
      queryParameters: const {'page': 1, 'limit': 50},
    );

    return _extractPostMaps(result).map(AdminPostModel.fromJson).toList();
  }

  List<AdminUserModel> _deriveUsers(List<AdminPost> posts) {
    final counts = <String, int>{};
    final latestPosts = <String, AdminPost>{};

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
