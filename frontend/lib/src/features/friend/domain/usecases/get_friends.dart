import '../entities/friend.dart';
import '../repositories/friend_repository.dart';

class GetFriends {
  final FriendRepository repository;

  GetFriends(this.repository);

  Future<List<Friend>> call() {
    return repository.getFriends();
  }
}
