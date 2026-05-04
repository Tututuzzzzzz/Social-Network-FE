import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../models/admin_post_detail_model.dart';
import '../models/admin_post_model.dart';

abstract class AdminPostRemoteDataSource {
  Future<List<AdminPostModel>> fetchPosts();

  Future<AdminPostDetailModel> fetchPostDetail(String postId);

  Future<void> deletePost(String postId);
}

class AdminPostRemoteDataSourceImpl implements AdminPostRemoteDataSource {
  final ApiClient _apiClient;

  const AdminPostRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<AdminPostModel>> fetchPosts() async {
    final result = await _apiClient.get(
      ApiConstants.postsFeed,
      queryParameters: const {'page': 1, 'limit': 50},
    );

    return _extractMaps(result).map(AdminPostModel.fromJson).toList();
  }

  @override
  Future<AdminPostDetailModel> fetchPostDetail(String postId) async {
    final postResult = await _apiClient.get(ApiConstants.postById(postId));
    final commentsResult = await _apiClient.get(
      ApiConstants.postComments(postId),
    );

    return AdminPostDetailModel.fromResponses(
      postJson: _extractMap(postResult),
      commentsResponse: commentsResult,
    );
  }

  @override
  Future<void> deletePost(String postId) {
    return _apiClient.delete(ApiConstants.postById(postId));
  }

  Map<String, dynamic> _extractMap(dynamic result) {
    if (result is Map) {
      final map = Map<String, dynamic>.from(result);
      final data = map['data'];
      if (data is Map) {
        final dataMap = Map<String, dynamic>.from(data);
        for (final key in ['post', 'item', 'doc']) {
          final value = dataMap[key];
          if (value is Map) {
            return Map<String, dynamic>.from(value);
          }
        }
        return dataMap;
      }
      return map;
    }

    return const {};
  }

  List<Map<String, dynamic>> _extractMaps(dynamic result) {
    if (result is Map) {
      final map = Map<String, dynamic>.from(result);
      final data = map['data'];
      if (data is Map && data['items'] is List) {
        return _mapsFromList(data['items'] as List);
      }
      if (data is Map && data['posts'] is List) {
        return _mapsFromList(data['posts'] as List);
      }
      if (data is Map && data['docs'] is List) {
        return _mapsFromList(data['docs'] as List);
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
