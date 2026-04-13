import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/chat_entity.dart';
import '../../../domain/usecases/fetch_chat_items_usecase.dart';
import '../../../domain/usecases/usecase_params.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchChatItemsUseCase _fetchItemsUseCase;

  ChatBloc(this._fetchItemsUseCase) : super(const ChatInitialState()) {
    on<ChatFetchedEvent>(_onFetched);
  }

  Future<void> _onFetched(
    ChatFetchedEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoadingState());

    final result = await _fetchItemsUseCase.call(
      ChatQueryParams(page: event.page),
    );

    result.fold(
      (failure) => emit(const ChatFailureState('Unable to load data')),
      (items) => emit(ChatSuccessState(items)),
    );
  }
}
