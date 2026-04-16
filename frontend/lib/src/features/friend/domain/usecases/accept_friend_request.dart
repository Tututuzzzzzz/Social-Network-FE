import '../repositories/friend_repository.dart';

class AcceptFriendRequest {
  final FriendRepository repository;

  AcceptFriendRequest(this.repository);

  Future<void> call(String requestId) async {
    return repository.acceptFriendRequest(requestId);
  }
}
