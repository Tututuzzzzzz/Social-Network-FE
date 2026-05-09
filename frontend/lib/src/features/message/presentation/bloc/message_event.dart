import 'package:equatable/equatable.dart';

import '../../../chat/domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';

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
