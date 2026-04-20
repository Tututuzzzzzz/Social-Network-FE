import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_datasource.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;
  final ChatLocalDataSource _localDataSource;

  ChatRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, List<ChatEntity>>> fetchItems() async {
    try {
      final remoteItems = await _remoteDataSource.fetchItems();
      if (remoteItems.isNotEmpty) {
        return right(remoteItems);
      }

      final localItems = await _localDataSource.fetchItems();
      return right(localItems);
    } catch (_) {
      return left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ChatEntity>> createDirectConversation({
    required String recipientId,
  }) async {
    try {
      final item = await _remoteDataSource.createDirectConversation(
        recipientId: recipientId,
      );
      return right(item);
    } catch (_) {
      return left(ServerFailure());
    }
  }
}
