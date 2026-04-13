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
    on<ChatThreadPinToggledEvent>(_onPinToggled);
    on<ChatThreadHiddenChangedEvent>(_onHiddenChanged);
    on<ChatThreadDeletedEvent>(_onDeleted);
    on<ChatThreadPreviewUpdatedEvent>(_onPreviewUpdated);
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
      (items) => emit(ChatSuccessState(_sortedItems(items))),
    );
  }

  void _onPinToggled(ChatThreadPinToggledEvent event, Emitter<ChatState> emit) {
    final currentItems = _itemsFromState();
    if (currentItems == null) {
      return;
    }

    final updatedItems = currentItems.map((item) {
      if (item.id != event.threadId) {
        return item;
      }
      return item.copyWith(isPinned: !item.isPinned);
    }).toList();

    emit(ChatSuccessState(_sortedItems(updatedItems)));
  }

  void _onHiddenChanged(
    ChatThreadHiddenChangedEvent event,
    Emitter<ChatState> emit,
  ) {
    final currentItems = _itemsFromState();
    if (currentItems == null) {
      return;
    }

    final updatedItems = currentItems.map((item) {
      if (item.id != event.threadId) {
        return item;
      }
      return item.copyWith(isHidden: event.isHidden);
    }).toList();

    emit(ChatSuccessState(_sortedItems(updatedItems)));
  }

  void _onDeleted(ChatThreadDeletedEvent event, Emitter<ChatState> emit) {
    final currentItems = _itemsFromState();
    if (currentItems == null) {
      return;
    }

    final updatedItems = currentItems
        .where((item) => item.id != event.threadId)
        .toList();

    emit(ChatSuccessState(_sortedItems(updatedItems)));
  }

  void _onPreviewUpdated(
    ChatThreadPreviewUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    final currentItems = _itemsFromState();
    if (currentItems == null) {
      return;
    }

    final updatedItems = currentItems.map((item) {
      if (item.id != event.thread.id) {
        return item;
      }
      return item.copyWith(
        messagePreview: event.thread.messagePreview,
        timeLabel: event.thread.timeLabel,
        fullConversation: event.thread.fullConversation,
      );
    }).toList();

    emit(ChatSuccessState(_sortedItems(updatedItems)));
  }

  List<ChatEntity>? _itemsFromState() {
    final currentState = state;
    if (currentState is ChatSuccessState) {
      return currentState.items;
    }
    return null;
  }

  List<ChatEntity> _sortedItems(List<ChatEntity> items) {
    final sorted = [...items];
    sorted.sort((a, b) {
      if (a.isHidden != b.isHidden) {
        return a.isHidden ? 1 : -1;
      }
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return 0;
    });
    return sorted;
  }
}
