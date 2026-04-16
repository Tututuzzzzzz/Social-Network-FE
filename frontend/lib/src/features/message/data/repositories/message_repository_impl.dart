import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/message_remote_datasource.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDataSource _remoteDataSource;

  MessageRepositoryImpl(this._remoteDataSource);

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
