import '../entities/friend_request.dart';

abstract class FriendRepository {
  Future<List<FriendRequest>> getFriendRequests();
  Future<void> acceptFriendRequest(String requestId);
  Future<void> rejectFriendRequest(String requestId);
}
