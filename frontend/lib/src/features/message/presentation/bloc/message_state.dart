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

class MessageHistoryBootstrapping extends MessageState {}

class MessageHistoryBootstrapFinished extends MessageState {}

class MessageHistoryCacheHydrated extends MessageState {
  final MessageHistoryPageEntity page;

  const MessageHistoryCacheHydrated(this.page);

  @override
  List<Object?> get props => [page];
}

class MessageHistoryRemoteHydrated extends MessageState {
  final MessageHistoryPageEntity page;

  const MessageHistoryRemoteHydrated(this.page);

  @override
  List<Object?> get props => [page];
}

class MessageHistoryOlderLoading extends MessageState {}

class MessageHistoryOlderLoaded extends MessageState {
  final MessageHistoryPageEntity page;

  const MessageHistoryOlderLoaded(this.page);

  @override
  List<Object?> get props => [page];
}

class MessageHistoryOlderLoadFinished extends MessageState {}
