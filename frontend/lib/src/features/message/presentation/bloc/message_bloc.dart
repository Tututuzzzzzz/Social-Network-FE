import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/realtime/realtime_socket_service.dart';
import '../../../chat/domain/entities/chat_entity.dart';
import '../../data/models/message_model.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/fetch_conversation_history_usecase.dart';
import '../../domain/usecases/load_cached_conversation_history_usecase.dart';
import '../../domain/usecases/mark_all_messages_as_read_usecase.dart';
import '../../domain/usecases/save_cached_conversation_history_usecase.dart';
import '../../domain/usecases/send_direct_text_usecase.dart';
import '../../domain/usecases/send_group_text_usecase.dart';
import '../../domain/usecases/usecase_params.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final SendDirectTextUseCase _sendDirectTextUseCase;
  final SendGroupTextUseCase _sendGroupTextUseCase;
  final FetchConversationHistoryUseCase _fetchConversationHistoryUseCase;
  final LoadCachedConversationHistoryUseCase
  _loadCachedConversationHistoryUseCase;
  final SaveCachedConversationHistoryUseCase
  _saveCachedConversationHistoryUseCase;
  final MarkAllMessagesAsReadUseCase _markAllMessagesAsReadUseCase;
  final RealtimeSocketService _realtimeSocketService;

  StreamSubscription<Map<String, dynamic>>? _newMessageSubscription;
  final Set<String> _knownMessageIds = <String>{};
  ChatEntity? _thread;
  String _currentUserId = '';
  bool _hasMarkedRead = false;
  String? _lastMarkedMessageId;
  int _historyLimit = 30;

  MessageBloc(
    this._sendDirectTextUseCase,
    this._sendGroupTextUseCase,
    this._fetchConversationHistoryUseCase,
    this._loadCachedConversationHistoryUseCase,
    this._saveCachedConversationHistoryUseCase,
    this._markAllMessagesAsReadUseCase,
    this._realtimeSocketService,
  ) : super(MessageChatRoomState.initial()) {
    on<MessageChatRoomStarted>(_onChatRoomStarted);
    on<MessageRealtimeMessageReceived>(_onRealtimeMessageReceived);
    on<SendDirectTextEvent>(_onSendDirectText);
    on<SendGroupTextEvent>(_onSendGroupText);
    on<MessageHistoryLoadOlderRequested>(_onHistoryLoadOlderRequested);
  }

  @override
  Future<void> close() async {
    await _newMessageSubscription?.cancel();
    return super.close();
  }

  MessageChatRoomState _chatState() {
    final current = state;
    if (current is MessageChatRoomState) {
      return current;
    }
    return MessageChatRoomState.initial();
  }

  Future<void> _onChatRoomStarted(
    MessageChatRoomStarted event,
    Emitter<MessageState> emit,
  ) async {
    _thread = event.thread;
    _knownMessageIds.clear();
    _hasMarkedRead = false;
    _lastMarkedMessageId = null;
    _historyLimit = event.limit;

    final initialLines = _parseConversation(event.thread);
    emit(
      _chatState().copyWith(messages: initialLines, messageEntities: const []),
    );

    _currentUserId = await _realtimeSocketService.getCurrentUserId();
    await _setupRealtime();
    await _bootstrapHistory(
      conversationId: event.thread.id,
      limit: event.limit,
      emit: emit,
    );
  }

  Future<void> _onSendDirectText(
    SendDirectTextEvent event,
    Emitter<MessageState> emit,
  ) async {
    emit(_chatState().copyWith(isSending: true));

    final params = SendTextMessageParams(
      conversationId: event.conversationId,
      recipientId: event.recipientId,
      content: event.content,
    );

    final Either result = await _sendDirectTextUseCase(params);

    result.match(
      (l) => emit(
        _withError(
          _chatState().copyWith(isSending: false),
          'Failed to send message',
        ),
      ),
      (r) {
        final updated = _appendMessage(
          _chatState().copyWith(isSending: false),
          r,
          fallbackAuthor: 'You',
        );
        emit(updated);
        unawaited(_saveHistoryCache(updated));
      },
    );
  }

  Future<void> _onSendGroupText(
    SendGroupTextEvent event,
    Emitter<MessageState> emit,
  ) async {
    emit(_chatState().copyWith(isSending: true));

    final params = SendTextMessageParams(
      conversationId: event.conversationId,
      recipientId: '',
      content: event.content,
    );

    final Either result = await _sendGroupTextUseCase(params);

    result.match(
      (l) => emit(
        _withError(
          _chatState().copyWith(isSending: false),
          'Failed to send message',
        ),
      ),
      (r) {
        final updated = _appendMessage(
          _chatState().copyWith(isSending: false),
          r,
          fallbackAuthor: 'You',
        );
        emit(updated);
        unawaited(_saveHistoryCache(updated));
      },
    );
  }

  Future<void> _bootstrapHistory({
    required String conversationId,
    required int limit,
    required Emitter<MessageState> emit,
  }) async {
    emit(_chatState().copyWith(isBootstrappingHistory: true, clearError: true));

    var hasCache = false;

    final cachedResult = await _loadCachedConversationHistoryUseCase(
      ConversationHistoryCacheParams(conversationId: conversationId),
    );

    cachedResult.match((_) {}, (cachedPage) {
      if (cachedPage.messages.isNotEmpty) {
        hasCache = true;
        final latest = _chatState();
        final updated = _replaceHistory(
          latest,
          cachedPage.messages,
          hasMore: cachedPage.hasMore,
          nextCursor: cachedPage.nextCursor,
        ).copyWith(scrollToLatestVersion: latest.scrollToLatestVersion + 1);
        emit(updated);
      }
    });

    final firstPageResult = await _fetchConversationHistoryUseCase(
      FetchConversationHistoryParams(
        conversationId: conversationId,
        limit: limit,
      ),
    );

    await firstPageResult.match(
      (_) async {
        if (!hasCache) {
          emit(_withError(_chatState(), 'Unable to load messages'));
        }
      },
      (page) async {
        final latest = _chatState();
        final updated = _replaceHistory(
          latest,
          page.messages,
          hasMore: page.hasMore,
          nextCursor: page.nextCursor,
        ).copyWith(scrollToLatestVersion: latest.scrollToLatestVersion + 1);

        emit(updated);
        await _saveCachedConversationHistoryUseCase(
          SaveConversationHistoryCacheParams(
            conversationId: conversationId,
            page: page,
          ),
        );
      },
    );

    emit(_chatState().copyWith(isBootstrappingHistory: false));
  }

  Future<void> _onHistoryLoadOlderRequested(
    MessageHistoryLoadOlderRequested event,
    Emitter<MessageState> emit,
  ) async {
    final cursor = event.cursor.trim();
    final currentState = _chatState();
    if (cursor.isEmpty ||
        _thread?.id != event.conversationId ||
        currentState.isLoadingOlderHistory ||
        !currentState.hasMoreHistory) {
      return;
    }

    emit(currentState.copyWith(isLoadingOlderHistory: true));

    final result = await _fetchConversationHistoryUseCase(
      FetchConversationHistoryParams(
        conversationId: event.conversationId,
        limit: event.limit,
        cursor: cursor,
      ),
    );

    result.match(
      (_) {
        emit(
          _withError(
            _chatState().copyWith(isLoadingOlderHistory: false),
            'Unable to load older messages',
          ),
        );
      },
      (page) {
        final latest = _chatState();
        final updated =
            _prependOlderHistory(
              latest,
              page.messages,
              hasMore: page.hasMore,
              nextCursor: page.nextCursor,
            ).copyWith(
              isLoadingOlderHistory: false,
              restoreScrollVersion: latest.restoreScrollVersion + 1,
            );
        emit(updated);
        unawaited(_saveHistoryCache(updated));
      },
    );
  }

  Future<void> _onRealtimeMessageReceived(
    MessageRealtimeMessageReceived event,
    Emitter<MessageState> emit,
  ) async {
    final thread = _thread;
    if (thread == null || event.message.id.trim().isEmpty) {
      return;
    }

    if (event.message.conversationId.trim() != thread.id) {
      return;
    }

    final updated = _appendMessage(
      _chatState(),
      event.message,
      fallbackAuthor: thread.senderName.trim().isNotEmpty
          ? thread.senderName
          : 'Friend',
    );

    emit(updated);
    unawaited(_saveHistoryCache(updated));

    final senderId = event.message.senderId.trim();
    if (_currentUserId.isNotEmpty && senderId != _currentUserId) {
      await _markAllRead(
        conversationId: thread.id,
        lastMessageId: event.message.id,
      );
    }
  }

  Future<void> _setupRealtime() async {
    // ensureConnected() already called by AppShellPage.
    await _realtimeSocketService.ensureConnected();

    final thread = _thread;
    if (thread == null) {
      return;
    }

    _realtimeSocketService.joinConversation(thread.id);

    await _newMessageSubscription?.cancel();
    _newMessageSubscription = _realtimeSocketService.newMessageStream.listen((
      payload,
    ) {
      final message = _parseRealtimeMessage(payload);
      if (message != null) {
        add(MessageRealtimeMessageReceived(message));
      }
    });
  }

  MessageEntity? _parseRealtimeMessage(Map<String, dynamic> payload) {
    final thread = _thread;
    if (thread == null) {
      return null;
    }

    final conversationId = payload['conversationId']?.toString() ?? '';
    if (conversationId != thread.id) {
      return null;
    }

    final messageRaw = payload['message'];
    Map<String, dynamic>? messageMap;
    if (messageRaw is Map) {
      messageMap = Map<String, dynamic>.from(messageRaw);
    } else if (messageRaw is String) {
      try {
        final decoded = jsonDecode(messageRaw);
        if (decoded is Map) {
          messageMap = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        messageMap = null;
      }
    }

    if (messageMap == null) {
      return null;
    }

    final message = MessageModel.fromJson(messageMap);
    if (message.id.trim().isEmpty) {
      return null;
    }

    return message;
  }

  Future<void> _markAllRead({
    required String conversationId,
    String? lastMessageId,
  }) async {
    final normalizedLastId = lastMessageId?.trim();
    if (_hasMarkedRead && normalizedLastId == _lastMarkedMessageId) {
      return;
    }

    _hasMarkedRead = true;
    _lastMarkedMessageId = normalizedLastId;
    await _markAllMessagesAsReadUseCase(
      MarkAllMessagesAsReadParams(
        conversationId: conversationId,
        lastMessageId: normalizedLastId,
      ),
    );
  }

  Future<void> _saveHistoryCache(MessageChatRoomState current) async {
    final thread = _thread;
    if (thread == null || current.messageEntities.isEmpty) {
      return;
    }

    await _saveCachedConversationHistoryUseCase(
      SaveConversationHistoryCacheParams(
        conversationId: thread.id,
        page: MessageHistoryPageEntity(
          messages: List<MessageEntity>.from(current.messageEntities),
          hasMore: current.hasMoreHistory,
          limit: _historyLimit,
          nextCursor: current.nextCursor,
        ),
      ),
    );
  }

  MessageChatRoomState _replaceHistory(
    MessageChatRoomState current,
    List<MessageEntity> messages, {
    required bool hasMore,
    required String? nextCursor,
  }) {
    if (messages.isEmpty) {
      return current.copyWith(hasMoreHistory: hasMore, nextCursor: nextCursor);
    }

    final sorted = _sortByCreatedAtAsc(messages);
    final nextLines = <MessageLine>[];
    final nextEntities = <MessageEntity>[];
    final knownIds = <String>{};

    for (final message in sorted) {
      final line = _toMessageLine(
        message,
        fallbackAuthor: _defaultPeerAuthor(),
      );
      if (line == null) {
        continue;
      }

      final id = line.id.trim();
      if (id.isNotEmpty && knownIds.contains(id)) {
        continue;
      }

      if (id.isNotEmpty) {
        knownIds.add(id);
      }

      nextEntities.add(message);
      nextLines.add(line);
    }

    _knownMessageIds
      ..clear()
      ..addAll(knownIds);

    if (nextEntities.isNotEmpty) {
      final threadId = _thread?.id ?? '';
      if (threadId.isNotEmpty) {
        unawaited(
          _markAllRead(
            conversationId: threadId,
            lastMessageId: nextEntities.last.id,
          ),
        );
      }
    }

    return current.copyWith(
      messageEntities: nextEntities,
      messages: nextLines,
      hasMoreHistory: hasMore,
      nextCursor: nextCursor,
    );
  }

  MessageChatRoomState _prependOlderHistory(
    MessageChatRoomState current,
    List<MessageEntity> messages, {
    required bool hasMore,
    required String? nextCursor,
  }) {
    if (messages.isEmpty) {
      return current.copyWith(hasMoreHistory: hasMore, nextCursor: nextCursor);
    }

    final sorted = _sortByCreatedAtAsc(messages);
    final prependLines = <MessageLine>[];
    final prependEntities = <MessageEntity>[];

    for (final message in sorted) {
      final line = _toMessageLine(
        message,
        fallbackAuthor: _defaultPeerAuthor(),
      );

      if (line == null) {
        continue;
      }

      final id = line.id.trim();
      if (id.isNotEmpty && _knownMessageIds.contains(id)) {
        continue;
      }

      if (id.isNotEmpty) {
        _knownMessageIds.add(id);
      }

      prependEntities.add(message);
      prependLines.add(line);
    }

    if (prependLines.isEmpty) {
      return current.copyWith(hasMoreHistory: hasMore, nextCursor: nextCursor);
    }

    return current.copyWith(
      messageEntities: [...prependEntities, ...current.messageEntities],
      messages: [...prependLines, ...current.messages],
      hasMoreHistory: hasMore,
      nextCursor: nextCursor,
    );
  }

  MessageChatRoomState _appendMessage(
    MessageChatRoomState current,
    MessageEntity message, {
    required String fallbackAuthor,
  }) {
    final messageId = message.id.trim();
    if (messageId.isNotEmpty && _knownMessageIds.contains(messageId)) {
      return current;
    }

    final line = _toMessageLine(message, fallbackAuthor: fallbackAuthor);
    if (line == null) {
      return current;
    }

    if (messageId.isNotEmpty) {
      _knownMessageIds.add(messageId);
    }

    return current.copyWith(
      messageEntities: [...current.messageEntities, message],
      messages: [...current.messages, line],
    );
  }

  List<MessageEntity> _sortByCreatedAtAsc(List<MessageEntity> messages) {
    final sorted = List<MessageEntity>.from(messages);
    sorted.sort((a, b) {
      final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
      if (aTime != bTime) {
        return aTime.compareTo(bTime);
      }
      return a.id.compareTo(b.id);
    });
    return sorted;
  }

  String _defaultPeerAuthor() {
    final thread = _thread;
    if (thread == null) {
      return 'Friend';
    }

    final name = thread.senderName.trim();
    return name.isNotEmpty ? name : 'Friend';
  }

  MessageLine? _toMessageLine(
    MessageEntity message, {
    required String fallbackAuthor,
  }) {
    final content = message.content.trim();
    final text = content.isNotEmpty
        ? content
        : (message.media.isNotEmpty ? '[Attachment]' : '');

    if (text.isEmpty) {
      return null;
    }

    final senderId = message.senderId.trim();
    final fromMe =
        _currentUserId.isNotEmpty &&
        senderId.isNotEmpty &&
        senderId == _currentUserId;

    final senderName = message.senderName.trim();
    final author = fromMe
        ? 'You'
        : (senderName.isNotEmpty ? senderName : fallbackAuthor);

    return MessageLine(
      id: message.id.trim(),
      senderId: senderId,
      senderAvatarUrl: message.senderAvatarUrl,
      author: author,
      text: text,
      fromMe: fromMe,
      createdAt: message.createdAt?.toLocal(),
    );
  }

  List<MessageLine> _parseConversation(ChatEntity thread) {
    final lines = thread.fullConversation
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return [
        MessageLine(
          senderId: '',
          senderAvatarUrl: '',
          author: thread.senderName,
          text: thread.messagePreview,
          fromMe: false,
          createdAt: null,
        ),
      ];
    }

    return lines.map((line) {
      final separatorIndex = line.indexOf(':');
      if (separatorIndex <= 0) {
        return MessageLine(
          senderId: '',
          senderAvatarUrl: '',
          author: thread.senderName,
          text: line,
          fromMe: false,
          createdAt: null,
        );
      }

      final author = line.substring(0, separatorIndex).trim();
      final text = line.substring(separatorIndex + 1).trim();

      return MessageLine(
        senderId: '',
        senderAvatarUrl: '',
        author: author,
        text: text,
        fromMe: author.toLowerCase() == 'you',
        createdAt: null,
      );
    }).toList();
  }

  MessageChatRoomState _withError(
    MessageChatRoomState current,
    String message,
  ) {
    return current.copyWith(
      errorMessage: message,
      errorVersion: current.errorVersion + 1,
    );
  }
}
