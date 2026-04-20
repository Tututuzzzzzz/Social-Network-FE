import 'package:equatable/equatable.dart';

import '../entities/message_entity.dart';

class SendTextMessageParams extends Equatable {
  final String conversationId;
  final String recipientId;
  final String content;

  const SendTextMessageParams({
    required this.conversationId,
    required this.recipientId,
    required this.content,
  });

  @override
  List<Object?> get props => [conversationId, recipientId, content];
}

class SendMediaMessageParams extends Equatable {
  final String conversationId;
  final List<Map<String, dynamic>> media;
  final String? content;

  const SendMediaMessageParams({
    required this.conversationId,
    required this.media,
    this.content,
  });

  @override
  List<Object?> get props => [conversationId, media, content];
}

class SendMessageParams extends Equatable {
  final String conversationId;
  final String? content;
  final List<Map<String, dynamic>>? media;

  const SendMessageParams({
    required this.conversationId,
    this.content,
    this.media,
  });

  @override
  List<Object?> get props => [conversationId, content, media];
}

class MessageReactionParams extends Equatable {
  final String messageId;
  final String emoji;

  const MessageReactionParams({required this.messageId, required this.emoji});

  @override
  List<Object?> get props => [messageId, emoji];
}

class MarkMessageAsReadParams extends Equatable {
  final String conversationId;
  final String messageId;

  const MarkMessageAsReadParams({
    required this.conversationId,
    required this.messageId,
  });

  @override
  List<Object?> get props => [conversationId, messageId];
}

class MarkAllMessagesAsReadParams extends Equatable {
  final String conversationId;
  final String? lastMessageId;

  const MarkAllMessagesAsReadParams({
    required this.conversationId,
    this.lastMessageId,
  });

  @override
  List<Object?> get props => [conversationId, lastMessageId];
}

class FetchConversationHistoryParams extends Equatable {
  final String conversationId;
  final int limit;
  final String? cursor;

  const FetchConversationHistoryParams({
    required this.conversationId,
    this.limit = 30,
    this.cursor,
  });

  @override
  List<Object?> get props => [conversationId, limit, cursor];
}

class ConversationHistoryCacheParams extends Equatable {
  final String conversationId;

  const ConversationHistoryCacheParams({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];
}

class SaveConversationHistoryCacheParams extends Equatable {
  final String conversationId;
  final MessageHistoryPageEntity page;

  const SaveConversationHistoryCacheParams({
    required this.conversationId,
    required this.page,
  });

  @override
  List<Object?> get props => [conversationId, page];
}
