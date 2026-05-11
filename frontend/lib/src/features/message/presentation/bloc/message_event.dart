import 'package:equatable/equatable.dart';

import '../../../chat/domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/message_media_upload_file.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

class MessageChatRoomStarted extends MessageEvent {
  final ChatEntity thread;
  final int limit;

  const MessageChatRoomStarted({required this.thread, this.limit = 30});

  @override
  List<Object?> get props => [thread, limit];
}

class MessageRealtimeMessageReceived extends MessageEvent {
  final MessageEntity message;

  const MessageRealtimeMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageRealtimeMessageSeen extends MessageEvent {
  final Map<String, dynamic> payload;

  const MessageRealtimeMessageSeen(this.payload);

  @override
  List<Object?> get props => [payload];
}

class MessageRealtimeMessageDeleted extends MessageEvent {
  final Map<String, dynamic> payload;

  const MessageRealtimeMessageDeleted(this.payload);

  @override
  List<Object?> get props => [payload];
}

class MessageRealtimeMessageReaction extends MessageEvent {
  final Map<String, dynamic> payload;

  const MessageRealtimeMessageReaction(this.payload);

  @override
  List<Object?> get props => [payload];
}

class SendDirectTextEvent extends MessageEvent {
  final String conversationId;
  final String recipientId;
  final String content;

  const SendDirectTextEvent({
    required this.conversationId,
    required this.recipientId,
    required this.content,
  });

  @override
  List<Object?> get props => [conversationId, recipientId, content];
}

class SendGroupTextEvent extends MessageEvent {
  final String conversationId;
  final String content;

  const SendGroupTextEvent({
    required this.conversationId,
    required this.content,
  });

  @override
  List<Object?> get props => [conversationId, content];
}

class SendDirectMediaEvent extends MessageEvent {
  final String conversationId;
  final String recipientId;
  final List<MessageMediaUploadFile> files;
  final String? content;

  const SendDirectMediaEvent({
    required this.conversationId,
    required this.recipientId,
    required this.files,
    this.content,
  });

  @override
  List<Object?> get props => [conversationId, recipientId, files, content];
}

class SendGroupMediaEvent extends MessageEvent {
  final String conversationId;
  final List<MessageMediaUploadFile> files;
  final String? content;

  const SendGroupMediaEvent({
    required this.conversationId,
    required this.files,
    this.content,
  });

  @override
  List<Object?> get props => [conversationId, files, content];
}

class MessageHistoryLoadOlderRequested extends MessageEvent {
  final String conversationId;
  final String cursor;
  final int limit;

  const MessageHistoryLoadOlderRequested({
    required this.conversationId,
    required this.cursor,
    this.limit = 30,
  });

  @override
  List<Object?> get props => [conversationId, cursor, limit];
}

class MessageMarkAllReadRequested extends MessageEvent {
  final String conversationId;
  final String? lastMessageId;

  const MessageMarkAllReadRequested({
    required this.conversationId,
    this.lastMessageId,
  });

  @override
  List<Object?> get props => [conversationId, lastMessageId];
}

class MessageAddReactionRequested extends MessageEvent {
  final String messageId;
  final String emoji;

  const MessageAddReactionRequested({
    required this.messageId,
    required this.emoji,
  });

  @override
  List<Object?> get props => [messageId, emoji];
}

class MessageRemoveReactionRequested extends MessageEvent {
  final String messageId;
  final String emoji;

  const MessageRemoveReactionRequested({
    required this.messageId,
    required this.emoji,
  });

  @override
  List<Object?> get props => [messageId, emoji];
}

class MessageDeleteRequested extends MessageEvent {
  final String conversationId;
  final String messageId;

  const MessageDeleteRequested({
    required this.conversationId,
    required this.messageId,
  });

  @override
  List<Object?> get props => [conversationId, messageId];
}
