import 'package:equatable/equatable.dart';

import '../../domain/entities/message_entity.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {}

class MessageSending extends MessageState {}

class MessageSent extends MessageState {
  final MessageEntity message;

  const MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageError extends MessageState {
  final String message;

  const MessageError(this.message);

  @override
  List<Object?> get props => [message];
}
