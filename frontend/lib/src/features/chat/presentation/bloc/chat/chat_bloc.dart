import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/realtime/realtime_socket_service.dart';
import '../../../domain/entities/chat_entity.dart';
import '../../../domain/usecases/fetch_chat_items_usecase.dart';
import '../../../domain/usecases/usecase_params.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchChatItemsUseCase _fetchItemsUseCase;
  final RealtimeSocketService _realtimeSocketService;
  StreamSubscription? _messageNewSub;
  StreamSubscription? _conversationSeenSub;

  ChatBloc(this._fetchItemsUseCase, this._realtimeSocketService) : super(const ChatInitialState()) {
    on<ChatFetchedEvent>(_onFetched);
    on<ChatThreadPinToggledEvent>(_onPinToggled);
    on<ChatThreadHiddenChangedEvent>(_onHiddenChanged);
    on<ChatThreadDeletedEvent>(_onDeleted);
    on<ChatThreadPreviewUpdatedEvent>(_onPreviewUpdated);
    on<ChatThreadUnreadClearedEvent>(_onUnreadCleared);
    on<ChatMessageReceivedEvent>(_onMessageReceived);
    on<ChatConversationSeenEvent>(_onConversationSeen);

    _bindSocketListeners();
  }

  void _bindSocketListeners() {
    _messageNewSub = _realtimeSocketService.messageNewStream.listen((payload) {
      if (isClosed) return;
      final conversationId = payload['conversationId']?.toString() ?? '';
      final message = payload['message'];
      if (conversationId.isNotEmpty && message is Map) {
        add(ChatMessageReceivedEvent(conversationId, Map<String, dynamic>.from(message)));
      }
    });

    _conversationSeenSub = _realtimeSocketService.conversationSeenStream.listen((payload) {
      if (isClosed) return;
      final conversationId = payload['conversationId']?.toString() ?? '';
      if (conversationId.isNotEmpty) {
        add(ChatConversationSeenEvent(conversationId));
      }
    });
  }

  @override
  Future<void> close() {
    _messageNewSub?.cancel();
    _conversationSeenSub?.cancel();
    return super.close();
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
        unreadCount: event.thread.unreadCount,
      );
    }).toList();

    emit(ChatSuccessState(_sortedItems(updatedItems)));
  }

  void _onUnreadCleared(
    ChatThreadUnreadClearedEvent event,
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
      return item.copyWith(unreadCount: 0);
    }).toList();

    emit(ChatSuccessState(_sortedItems(updatedItems)));
  }

  void _onMessageReceived(
    ChatMessageReceivedEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentItems = _itemsFromState();
    if (currentItems == null) return;

    final currentUserId = await _realtimeSocketService.getCurrentUserId();
    final senderId = event.message['senderId'];
    final parsedSenderId = senderId is Map ? senderId['_id']?.toString() : senderId?.toString();
    final isFromMe = currentUserId.isNotEmpty && parsedSenderId == currentUserId;

    final content = event.message['content']?.toString() ?? '';
    final media = event.message['media'] as List?;
    final text = content.isNotEmpty ? content : ((media != null && media.isNotEmpty) ? '[Attachment]' : '');

    bool found = false;
    final updatedItems = currentItems.map((item) {
      if (item.id != event.conversationId) return item;
      found = true;
      return item.copyWith(
        messagePreview: text,
        timeLabel: 'Vừa xong', // Simplistic approach, will be updated properly by remote fetch later
        unreadCount: isFromMe ? item.unreadCount : item.unreadCount + 1,
      );
    }).toList();

    if (found) {
      emit(ChatSuccessState(_sortedItems(updatedItems)));
    } else {
      // If conversation is new, fetch the whole list again.
      add(const ChatFetchedEvent());
    }
  }

  void _onConversationSeen(
    ChatConversationSeenEvent event,
    Emitter<ChatState> emit,
  ) {
    add(ChatThreadUnreadClearedEvent(event.conversationId));
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
