import '../repositories/friend_repository.dart';

class SendFriendRequest {
  final FriendRepository repository;

  SendFriendRequest(this.repository);

  Future<void> call(String userId, {String? message}) async {
    return repository.sendFriendRequest(userId, message: message);
  }
}
