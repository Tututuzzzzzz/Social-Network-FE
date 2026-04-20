import 'package:equatable/equatable.dart';

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
