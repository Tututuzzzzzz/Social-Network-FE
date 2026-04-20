import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/message_entity.dart';

abstract class MessageRepository {
  Future<Either<Failure, MessageHistoryPageEntity>> fetchConversationHistory({
    required String conversationId,
    int limit,
    String? cursor,
  });

  Future<Either<Failure, MessageHistoryPageEntity>>
  loadCachedConversationHistory({required String conversationId});

  Future<Either<Failure, void>> saveCachedConversationHistory({
    required String conversationId,
    required MessageHistoryPageEntity page,
  });

  Future<Either<Failure, MessageEntity>> sendDirectText({
    required String conversationId,
    required String recipientId,
    required String content,
  });

  Future<Either<Failure, MessageActionResultEntity>> sendDirectMedia({
    required String conversationId,
    required List<Map<String, dynamic>> media,
    String? content,
  });

  Future<Either<Failure, MessageEntity>> sendGroupText({
    required String conversationId,
    required String content,
  });

  Future<Either<Failure, MessageActionResultEntity>> sendGroupMedia({
    required String conversationId,
    required List<Map<String, dynamic>> media,
    String? content,
  });

  Future<Either<Failure, MessageEntity>> sendDirectMessage({
    required String conversationId,
    String? content,
    List<Map<String, dynamic>>? media,
  });

  Future<Either<Failure, MessageEntity>> sendGroupMessage({
    required String conversationId,
    String? content,
    List<Map<String, dynamic>>? media,
  });

  Future<Either<Failure, MessageActionResultEntity>> addReaction({
    required String messageId,
    required String emoji,
  });

  Future<Either<Failure, MessageActionResultEntity>> removeReaction({
    required String messageId,
    required String emoji,
  });

  Future<Either<Failure, MessageActionResultEntity>> markMessageAsRead({
    required String conversationId,
    required String messageId,
  });

  Future<Either<Failure, MessageActionResultEntity>> markAllMessagesAsRead({
    required String conversationId,
    String? lastMessageId,
  });
}
