import '../entities/friend_request.dart';
import '../repositories/friend_repository.dart';

class GetFriendRequests {
  final FriendRepository repository;

  GetFriendRequests(this.repository);

  Future<List<FriendRequest>> call() async {
    return repository.getFriendRequests();
  }
}
