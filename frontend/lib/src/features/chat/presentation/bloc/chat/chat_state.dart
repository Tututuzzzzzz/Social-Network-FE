part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitialState extends ChatState {
  const ChatInitialState();
}

class ChatLoadingState extends ChatState {
  const ChatLoadingState();
}

class ChatSuccessState extends ChatState {
  final List<ChatEntity> items;

  const ChatSuccessState(this.items);

  @override
  List<Object?> get props => [items];
}

class ChatFailureState extends ChatState {
  final String message;

  const ChatFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
