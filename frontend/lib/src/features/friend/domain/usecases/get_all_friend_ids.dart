import '../repositories/friend_repository.dart';

class GetAllFriendIds {
  final FriendRepository repository;

  GetAllFriendIds(this.repository);

  Future<List<String>> call() {
    return repository.getAllFriendIds();
  }
}
