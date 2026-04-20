import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/message_model.dart';
import '../datasources/message_local_datasource.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/message_remote_datasource.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDataSource _remoteDataSource;
  final MessageLocalDataSource _localDataSource;

  MessageRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, MessageHistoryPageEntity>> fetchConversationHistory({
    required String conversationId,
    int limit = 30,
    String? cursor,
  }) async {
    try {
      final item = await _remoteDataSource.fetchConversationHistory(
        conversationId: conversationId,
        limit: limit,
        cursor: cursor,
      );
      return right(item);
    } catch (_) {
      if ((cursor?.trim().isNotEmpty ?? false)) {
        return left(ServerFailure());
      }

      try {
        final cached = await _localDataSource.loadConversationHistory(
          conversationId: conversationId,
        );

        if (cached != null) {
          return right(cached);
        }
      } on CacheException {
        return left(CacheFailure());
      }

      return left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MessageHistoryPageEntity>>
  loadCachedConversationHistory({required String conversationId}) async {
    try {
      final cached = await _localDataSource.loadConversationHistory(
        conversationId: conversationId,
      );

      return right(cached ?? const MessageHistoryPageEntity());
    } on CacheException {
      return left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveCachedConversationHistory({
    required String conversationId,
    required MessageHistoryPageEntity page,
  }) async {
    try {
      await _localDataSource.saveConversationHistory(
        conversationId: conversationId,
        page: MessageHistoryPageModel(
          messages: page.messages,
          hasMore: page.hasMore,
          limit: page.limit,
          nextCursor: page.nextCursor,
        ),
      );

      return right(null);
    } on CacheException {
      return left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendDirectText({
    required String conversationId,
    required String recipientId,
    required String content,
  }) async {
    try {
      final item = await _remoteDataSource.sendDirectText(
        conversationId: conversationId,
        recipientId: recipientId,
        content: content,
      );
      return right(item);
    } catch (_) {
      return left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MessageActionResultEntity>> sendDirectMedia({
    required String conversationId,
    required List<Map<String, dynamic>> media,
    String? content,
  }) async {
    try {
      final result = await _remoteDataSource.sendDirectMedia(
        conversationId: conversationId,
        media: media,
        content: content,
      );
      return right(result);
    } catch (_) {
      return left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendGroupText({
    required String conversationId,
    required String content,
  }) async {
    try {
      final item = await _remoteDataSource.sendGroupText(
        conversationId: conversationId,
        content: content,
      );
      return right(item);
    } catch (_) {
      return left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MessageActionResultEntity>> sendGroupMedia({
    required String conversationId,
    required List<Map<String, dynamic>> media,
    String? content,
  }) async {
    try {
      final result = await _remoteDataSource.sendGroupMedia(
        conversationId: conversationId,
        media: media,
        content: content,
      );
      return right(result);
    } catch (_) {
      return left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendDirectMessage({
    required String conversationId,
    String? content,
    List<Map<String, dynamic>>? media,
  }) async {
    try {
      final item = await _remoteDataSource.sendDirectMessage(
        conversationId: conversationId,
        content: content,
        media: media,
      );
      return right(item);
    } catch (_) {
      return left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendGroupMessage({
    required String conversationId,
    String? content,
    List<Map<String, dynamic>>? media,
  }) async {
    try {
      final item = await _remoteDataSource.sendGroupMessage(
        conversationId: conversationId,
        content: content,
        media: media,
      );
      return right(item);
    } catch (_) {
      return left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MessageActionResultEntity>> addReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final result = await _remoteDataSource.addReaction(
        messageId: messageId,
        emoji: emoji,
      );
      return right(result);
    } catch (_) {
      return left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MessageActionResultEntity>> removeReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final result = await _remoteDataSource.removeReaction(
        messageId: messageId,
        emoji: emoji,
      );
      return right(result);
    } catch (_) {
      return left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MessageActionResultEntity>> markMessageAsRead({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      final result = await _remoteDataSource.markMessageAsRead(
        conversationId: conversationId,
        messageId: messageId,
      );
      return right(result);
    } catch (_) {
      return left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MessageActionResultEntity>> markAllMessagesAsRead({
    required String conversationId,
    String? lastMessageId,
  }) async {
    try {
      final result = await _remoteDataSource.markAllMessagesAsRead(
        conversationId: conversationId,
        lastMessageId: lastMessageId,
      );
      return right(result);
    } catch (_) {
      return left(ServerFailure());
    }
  }
}
