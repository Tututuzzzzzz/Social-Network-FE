import 'package:equatable/equatable.dart';

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
