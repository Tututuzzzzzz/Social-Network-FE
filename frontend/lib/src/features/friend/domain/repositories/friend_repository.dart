import '../entities/friend_request.dart';

abstract class FriendRepository {
  Future<List<FriendRequest>> getFriendRequests();
  Future<void> sendFriendRequest(String userId, {String? message});
  Future<void> acceptFriendRequest(String requestId);
  Future<void> rejectFriendRequest(String requestId);
}
