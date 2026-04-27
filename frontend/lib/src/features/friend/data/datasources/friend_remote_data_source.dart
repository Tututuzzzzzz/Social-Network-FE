import '../models/friend_request_model.dart';

import '../../../../core/api/api_helper.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Remote data source for friend-related network calls using ApiHelper.
abstract class FriendRemoteDataSource {
  Future<List<FriendRequestModel>> fetchFriendRequests();
  Future<void> sendFriendRequest(String userId, {String? message});
  Future<void> acceptFriendRequest(String requestId);
  Future<void> rejectFriendRequest(String requestId);
}

class FriendRemoteDataSourceImpl implements FriendRemoteDataSource {
  final ApiHelper _apiHelper;
  const FriendRemoteDataSourceImpl(this._apiHelper);

  @override
  Future<List<FriendRequestModel>> fetchFriendRequests() async {
    try {
      final endpoint = ApiConstants.friendsRequests;
      final result = await _apiHelper.execute(
        method: Method.get,
        url: endpoint,
      );

      final data = _extractList(result);
      return data.map(FriendRequestModel.fromJson).toList();
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<void> sendFriendRequest(String userId, {String? message}) async {
    try {
      await _apiHelper.execute(
        method: Method.post,
        url: ApiConstants.friendsRequests,
        data: {
          'to': userId,
          if ((message ?? '').trim().isNotEmpty) 'message': message!.trim(),
        },
      );
      return;
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      final endpoint = ApiConstants.friendRequestAccept(requestId);
      await _apiHelper.execute(method: Method.post, url: endpoint);
      return;
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      final endpoint = ApiConstants.friendRequestReject(requestId);
      await _apiHelper.execute(method: Method.post, url: endpoint);
      return;
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> result) {
    final data = result['data'];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (data is Map) {
      final items = data['items'] ?? data['docs'] ?? data['results'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }

    final docs = result['docs'];
    if (docs is List) {
      return docs
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    final items = result['items'];
    if (items is List) {
      return items
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return const [];
  }
}
