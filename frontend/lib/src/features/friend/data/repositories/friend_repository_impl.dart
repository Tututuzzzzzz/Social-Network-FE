import '../datasources/friend_remote_data_source.dart';
import '../../domain/entities/friend_request.dart';
import '../../domain/repositories/friend_repository.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FriendRemoteDataSource remoteDataSource;

  FriendRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<FriendRequest>> getFriendRequests() async {
    final models = await remoteDataSource.fetchFriendRequests();
    return models
        .map(
          (m) => FriendRequest(
            id: m.id,
            fromUserId: m.fromUserId,
            fromUserName: m.fromUserName,
            avatarUrl: m.avatarUrl,
            createdAt: m.createdAt,
          ),
        )
        .toList();
  }

  @override
  Future<void> sendFriendRequest(String userId, {String? message}) async {
    await remoteDataSource.sendFriendRequest(userId, message: message);
  }

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    await remoteDataSource.acceptFriendRequest(requestId);
  }

  @override
  Future<void> rejectFriendRequest(String requestId) async {
    await remoteDataSource.rejectFriendRequest(requestId);
  }
}
