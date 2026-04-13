part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatFetchedEvent extends ChatEvent {
  final int page;

  const ChatFetchedEvent({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class ChatThreadPinToggledEvent extends ChatEvent {
  final String threadId;

  const ChatThreadPinToggledEvent(this.threadId);

  @override
  List<Object?> get props => [threadId];
}

class ChatThreadHiddenChangedEvent extends ChatEvent {
  final String threadId;
  final bool isHidden;

  const ChatThreadHiddenChangedEvent(this.threadId, {required this.isHidden});

  @override
  List<Object?> get props => [threadId, isHidden];
}

class ChatThreadDeletedEvent extends ChatEvent {
  final String threadId;

  const ChatThreadDeletedEvent(this.threadId);

  @override
  List<Object?> get props => [threadId];
}

class ChatThreadPreviewUpdatedEvent extends ChatEvent {
  final ChatEntity thread;

  const ChatThreadPreviewUpdatedEvent(this.thread);

  @override
  List<Object?> get props => [thread];
}
