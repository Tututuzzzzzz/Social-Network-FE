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
