import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/usecases/fetch_conversation_history_usecase.dart';
import '../../domain/usecases/load_cached_conversation_history_usecase.dart';
import '../../domain/usecases/save_cached_conversation_history_usecase.dart';
import '../../domain/usecases/send_direct_text_usecase.dart';
import '../../domain/usecases/usecase_params.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final SendDirectTextUseCase _sendDirectTextUseCase;
  final FetchConversationHistoryUseCase _fetchConversationHistoryUseCase;
  final LoadCachedConversationHistoryUseCase
  _loadCachedConversationHistoryUseCase;
  final SaveCachedConversationHistoryUseCase
  _saveCachedConversationHistoryUseCase;

  MessageBloc(
    this._sendDirectTextUseCase,
    this._fetchConversationHistoryUseCase,
    this._loadCachedConversationHistoryUseCase,
    this._saveCachedConversationHistoryUseCase,
  ) : super(MessageInitial()) {
    on<SendDirectTextEvent>(_onSendDirectText);
    on<MessageHistoryBootstrapRequested>(_onHistoryBootstrapRequested);
    on<MessageHistoryLoadOlderRequested>(_onHistoryLoadOlderRequested);
    on<MessageHistoryCacheSaveRequested>(_onHistoryCacheSaveRequested);
  }

  Future<void> _onSendDirectText(
    SendDirectTextEvent event,
    Emitter<MessageState> emit,
  ) async {
    emit(MessageSending());

    final params = SendTextMessageParams(
      conversationId: event.conversationId,
      recipientId: event.recipientId,
      content: event.content,
    );

    final Either result = await _sendDirectTextUseCase(params);

    result.match(
      (l) => emit(const MessageError('Failed to send message')),
      (r) => emit(MessageSent(r)),
    );
  }

  Future<void> _onHistoryBootstrapRequested(
    MessageHistoryBootstrapRequested event,
    Emitter<MessageState> emit,
  ) async {
    emit(MessageHistoryBootstrapping());

    var hasCache = false;

    final cachedResult = await _loadCachedConversationHistoryUseCase(
      ConversationHistoryCacheParams(conversationId: event.conversationId),
    );

    cachedResult.match((_) {}, (cachedPage) {
      if (cachedPage.messages.isNotEmpty) {
        hasCache = true;
        emit(MessageHistoryCacheHydrated(cachedPage));
      }
    });

    final firstPageResult = await _fetchConversationHistoryUseCase(
      FetchConversationHistoryParams(
        conversationId: event.conversationId,
        limit: event.limit,
      ),
    );

    await firstPageResult.match(
      (_) async {
        if (!hasCache) {
          emit(const MessageError('Unable to load messages'));
        }
      },
      (page) async {
        emit(MessageHistoryRemoteHydrated(page));

        await _saveCachedConversationHistoryUseCase(
          SaveConversationHistoryCacheParams(
            conversationId: event.conversationId,
            page: page,
          ),
        );
      },
    );

    emit(MessageHistoryBootstrapFinished());
  }

  Future<void> _onHistoryLoadOlderRequested(
    MessageHistoryLoadOlderRequested event,
    Emitter<MessageState> emit,
  ) async {
    final cursor = event.cursor.trim();
    if (cursor.isEmpty) {
      return;
    }

    emit(MessageHistoryOlderLoading());

    final result = await _fetchConversationHistoryUseCase(
      FetchConversationHistoryParams(
        conversationId: event.conversationId,
        limit: event.limit,
        cursor: cursor,
      ),
    );

    result.match(
      (_) => emit(const MessageError('Unable to load older messages')),
      (page) => emit(MessageHistoryOlderLoaded(page)),
    );

    emit(MessageHistoryOlderLoadFinished());
  }

  Future<void> _onHistoryCacheSaveRequested(
    MessageHistoryCacheSaveRequested event,
    Emitter<MessageState> emit,
  ) async {
    await _saveCachedConversationHistoryUseCase(
      SaveConversationHistoryCacheParams(
        conversationId: event.conversationId,
        page: event.page,
      ),
    );
  }
}
