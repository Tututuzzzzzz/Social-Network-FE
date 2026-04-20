import 'package:equatable/equatable.dart';

import '../../domain/entities/message_entity.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
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

class MessageHistoryBootstrapRequested extends MessageEvent {
  final String conversationId;
  final int limit;

  const MessageHistoryBootstrapRequested({
    required this.conversationId,
    this.limit = 30,
  });

  @override
  List<Object?> get props => [conversationId, limit];
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

class MessageHistoryCacheSaveRequested extends MessageEvent {
  final String conversationId;
  final MessageHistoryPageEntity page;

  const MessageHistoryCacheSaveRequested({
    required this.conversationId,
    required this.page,
  });

  @override
  List<Object?> get props => [conversationId, page];
}
