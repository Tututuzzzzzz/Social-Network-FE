import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/realtime/realtime_socket_service.dart';
import '../../../chat/domain/entities/chat_entity.dart';
import '../../data/models/message_model.dart';
import '../../domain/entities/message_entity.dart';
import '../bloc/message_bloc.dart';
import '../bloc/message_event.dart';
import '../bloc/message_state.dart';

class MessageChatRoomPage extends StatefulWidget {
  final ChatEntity thread;

  const MessageChatRoomPage({super.key, required this.thread});

  @override
  State<MessageChatRoomPage> createState() => _MessageChatRoomPageState();
}

class _MessageChatRoomPageState extends State<MessageChatRoomPage> {
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _historyScrollController = ScrollController();
  final List<_MessageLine> _messages = [];
  final List<MessageEntity> _messageEntities = [];
  final Set<String> _knownMessageIds = <String>{};

  static const int _historyPageLimit = 30;

  late final RealtimeSocketService _realtimeSocketService;

  StreamSubscription<Map<String, dynamic>>? _newMessageSubscription;

  String _currentUserId = '';
  String? _nextCursor;
  bool _hasMoreHistory = true;
  bool _isLoadingOlderHistory = false;
  bool _isBootstrappingHistory = false;
  double _previousMaxScrollExtentBeforeOlderLoad = 0.0;

  @override
  void initState() {
    super.initState();
    _realtimeSocketService = getIt<RealtimeSocketService>();

    _messages.addAll(_parseConversation(widget.thread));
    _historyScrollController.addListener(_onHistoryScroll);
    unawaited(_initializeRoomState());
  }

  @override
  void dispose() {
    _newMessageSubscription?.cancel();
    _historyScrollController
      ..removeListener(_onHistoryScroll)
      ..dispose();
    _composerController.dispose();
    super.dispose();
  }

  Future<void> _initializeRoomState() async {
    _currentUserId = await _realtimeSocketService.getCurrentUserId();
    _bootstrapHistory();
    await _setupRealtime();
  }

  Future<void> _setupRealtime() async {
    await _realtimeSocketService.ensureConnected();

    _realtimeSocketService.joinConversation(widget.thread.id);

    await _newMessageSubscription?.cancel();
    _newMessageSubscription = _realtimeSocketService.newMessageStream.listen(
      _onNewRealtimeMessage,
    );
  }

  void _onNewRealtimeMessage(Map<String, dynamic> payload) {
    final conversationId = payload['conversationId']?.toString() ?? '';
    if (conversationId != widget.thread.id) {
      return;
    }

    final messageRaw = payload['message'];
    if (messageRaw is! Map) {
      return;
    }

    final message = MessageModel.fromJson(
      Map<String, dynamic>.from(messageRaw),
    );
    _appendMessage(
      message,
      fallbackAuthor: widget.thread.senderName.trim().isNotEmpty
          ? widget.thread.senderName
          : 'Friend',
    );
  }

  void _bootstrapHistory() {
    if (!mounted) {
      return;
    }

    context.read<MessageBloc>().add(
      MessageHistoryBootstrapRequested(
        conversationId: widget.thread.id,
        limit: _historyPageLimit,
      ),
    );
  }

  void _onHistoryScroll() {
    if (!_historyScrollController.hasClients) {
      return;
    }

    if (_historyScrollController.position.pixels <= 80) {
      unawaited(_loadOlderHistory());
    }
  }

  Future<void> _loadOlderHistory() async {
    final cursor = _nextCursor?.trim();
    if (_isLoadingOlderHistory ||
        !_hasMoreHistory ||
        cursor == null ||
        cursor.isEmpty) {
      return;
    }

    _previousMaxScrollExtentBeforeOlderLoad =
        _historyScrollController.hasClients
        ? _historyScrollController.position.maxScrollExtent
        : 0.0;

    context.read<MessageBloc>().add(
      MessageHistoryLoadOlderRequested(
        conversationId: widget.thread.id,
        cursor: cursor,
        limit: _historyPageLimit,
      ),
    );
  }

  void _requestPersistHistoryCache({int? limit}) {
    if (_messageEntities.isEmpty) {
      return;
    }

    context.read<MessageBloc>().add(
      MessageHistoryCacheSaveRequested(
        conversationId: widget.thread.id,
        page: MessageHistoryPageEntity(
          messages: List<MessageEntity>.from(_messageEntities),
          hasMore: _hasMoreHistory,
          limit: limit ?? _historyPageLimit,
          nextCursor: _nextCursor,
        ),
      ),
    );
  }

  void _restoreScrollAfterOlderLoaded() {
    if (!_historyScrollController.hasClients) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_historyScrollController.hasClients) {
        return;
      }

      final newMaxScrollExtent =
          _historyScrollController.position.maxScrollExtent;
      final delta =
          newMaxScrollExtent - _previousMaxScrollExtentBeforeOlderLoad;
      if (delta > 0) {
        _historyScrollController.jumpTo(
          _historyScrollController.position.pixels + delta,
        );
      }
    });
  }

  void _scrollToLatestAfterHydration() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_historyScrollController.hasClients) {
        return;
      }

      final maxScrollExtent = _historyScrollController.position.maxScrollExtent;
      _historyScrollController.jumpTo(maxScrollExtent);
    });
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
    final name = widget.thread.senderName.trim();
    return name.isNotEmpty ? name : 'Friend';
  }

  _MessageLine? _toMessageLine(
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

    return _MessageLine(
      id: message.id.trim(),
      author: fromMe ? 'You' : fallbackAuthor,
      text: text,
      fromMe: fromMe,
    );
  }

  void _replaceHistory(List<MessageEntity> messages) {
    if (messages.isEmpty) {
      return;
    }

    final sorted = _sortByCreatedAtAsc(messages);
    final nextLines = <_MessageLine>[];
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

    if (!mounted) {
      return;
    }

    setState(() {
      _messageEntities
        ..clear()
        ..addAll(nextEntities);
      _messages
        ..clear()
        ..addAll(nextLines);
      _knownMessageIds
        ..clear()
        ..addAll(knownIds);
    });
  }

  void _prependOlderHistory(List<MessageEntity> messages) {
    final sorted = _sortByCreatedAtAsc(messages);
    final prependLines = <_MessageLine>[];
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

    if (prependLines.isEmpty || !mounted) {
      return;
    }

    setState(() {
      _messageEntities.insertAll(0, prependEntities);
      _messages.insertAll(0, prependLines);
    });
  }

  List<_MessageLine> _parseConversation(ChatEntity thread) {
    final lines = thread.fullConversation
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return [
        _MessageLine(
          author: thread.senderName,
          text: thread.messagePreview,
          fromMe: false,
        ),
      ];
    }

    return lines.map((line) {
      final separatorIndex = line.indexOf(':');
      if (separatorIndex <= 0) {
        return _MessageLine(
          author: thread.senderName,
          text: line,
          fromMe: false,
        );
      }

      final author = line.substring(0, separatorIndex).trim();
      final text = line.substring(separatorIndex + 1).trim();

      return _MessageLine(
        author: author,
        text: text,
        fromMe: author.toLowerCase() == 'you',
      );
    }).toList();
  }

  String _displayName() {
    final value = widget.thread.senderName.trim();
    return value.isEmpty ? 'Conversation' : value;
  }

  ChatEntity _buildUpdatedThread() {
    final lastMessage = _messages.isNotEmpty ? _messages.last.text.trim() : '';
    final preview = lastMessage.isNotEmpty
        ? lastMessage
        : (widget.thread.messagePreview.trim().isNotEmpty
              ? widget.thread.messagePreview.trim()
              : 'Start chatting...');

    final fullConversation = _messages
        .map((line) => '${line.author}: ${line.text}')
        .join('\n');

    return widget.thread.copyWith(
      messagePreview: preview,
      timeLabel: 'now',
      fullConversation: fullConversation,
    );
  }

  void _closeWithResult() {
    Navigator.of(context).pop(_buildUpdatedThread());
  }

  void _onSendPressed(BuildContext blocContext) {
    final text = _composerController.text.trim();
    if (text.isEmpty) {
      return;
    }

    final recipientId = widget.thread.recipientId.trim();
    if (recipientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Khong xac dinh duoc nguoi nhan tin nhan'),
        ),
      );
      return;
    }

    blocContext.read<MessageBloc>().add(
      SendDirectTextEvent(
        conversationId: widget.thread.id,
        recipientId: recipientId,
        content: text,
      ),
    );
  }

  void _appendSentMessage(MessageEntity sentMessage) {
    _composerController.clear();
    _appendMessage(sentMessage, fallbackAuthor: 'You');
  }

  void _appendMessage(MessageEntity message, {required String fallbackAuthor}) {
    final messageId = message.id.trim();
    if (messageId.isNotEmpty && _knownMessageIds.contains(messageId)) {
      return;
    }

    final line = _toMessageLine(message, fallbackAuthor: fallbackAuthor);
    if (line == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      if (messageId.isNotEmpty) {
        _knownMessageIds.add(messageId);
      }

      _messageEntities.add(message);
      _messages.add(line);
    });

    _requestPersistHistoryCache();
  }

  @override
  Widget build(BuildContext context) {
    final threadName = _displayName();

    return PopScope<ChatEntity>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _closeWithResult();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _closeWithResult,
            icon: const Icon(Icons.arrow_back),
          ),
          title: Row(
            children: [
              CircleAvatar(radius: 16, child: Text(threadName.substring(0, 1))),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      threadName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      widget.thread.isOnline ? 'Active now' : 'Away',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.call_outlined)),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.videocam_outlined),
            ),
          ],
        ),
        body: BlocConsumer<MessageBloc, MessageState>(
          listener: (context, state) {
            if (state is MessageHistoryBootstrapping) {
              setState(() {
                _isBootstrappingHistory = true;
              });
            }

            if (state is MessageHistoryBootstrapFinished) {
              setState(() {
                _isBootstrappingHistory = false;
              });
            }

            if (state is MessageHistoryCacheHydrated) {
              if (state.page.messages.isNotEmpty) {
                _replaceHistory(state.page.messages);
                _nextCursor = state.page.nextCursor;
                _hasMoreHistory = state.page.hasMore;
                _scrollToLatestAfterHydration();
              }
            }

            if (state is MessageHistoryRemoteHydrated) {
              _replaceHistory(state.page.messages);
              _nextCursor = state.page.nextCursor;
              _hasMoreHistory = state.page.hasMore;
              _scrollToLatestAfterHydration();
              _requestPersistHistoryCache(limit: state.page.limit);
            }

            if (state is MessageHistoryOlderLoading) {
              setState(() {
                _isLoadingOlderHistory = true;
              });
            }

            if (state is MessageHistoryOlderLoaded) {
              _prependOlderHistory(state.page.messages);
              _nextCursor = state.page.nextCursor;
              _hasMoreHistory = state.page.hasMore;
              _requestPersistHistoryCache(limit: state.page.limit);
              _restoreScrollAfterOlderLoaded();
            }

            if (state is MessageHistoryOlderLoadFinished) {
              setState(() {
                _isLoadingOlderHistory = false;
              });
            }

            if (state is MessageSent) {
              _appendSentMessage(state.message);
            }

            if (state is MessageError) {
              if (_isBootstrappingHistory || _isLoadingOlderHistory) {
                setState(() {
                  _isBootstrappingHistory = false;
                  _isLoadingOlderHistory = false;
                });
              }

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (blocContext, state) {
            final isSending = state is MessageSending;

            return SafeArea(
              child: Column(
                children: [
                  if (_isBootstrappingHistory)
                    const LinearProgressIndicator(minHeight: 2),
                  if (_isLoadingOlderHistory)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  Expanded(
                    child: ListView.separated(
                      controller: _historyScrollController,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                      itemCount: _messages.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = _messages[index];
                        return Align(
                          alignment: item.fromMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: item.fromMe
                                    ? const Color(0xFF4A9BFF)
                                    : const Color(0xFFF1F4F8),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 9,
                                ),
                                child: Column(
                                  crossAxisAlignment: item.fromMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    if (!item.fromMe)
                                      Text(
                                        item.author,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    if (!item.fromMe) const SizedBox(height: 2),
                                    Text(
                                      item.text,
                                      style: TextStyle(
                                        color: item.fromMe
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _composerController,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _onSendPressed(blocContext),
                            decoration: InputDecoration(
                              hintText: 'Type a message',
                              filled: true,
                              fillColor: const Color(0xFFF3F6FA),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: isSending
                              ? null
                              : () => _onSendPressed(blocContext),
                          icon: isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : SvgPicture.string(
                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-send-icon lucide-send"><path d="M14.536 21.686a.5.5 0 0 0 .937-.024l6.5-19a.496.496 0 0 0-.635-.635l-19 6.5a.5.5 0 0 0-.024.937l7.93 3.18a2 2 0 0 1 1.112 1.11z"/><path d="m21.854 2.147-10.94 10.939"/></svg>',
                                  width: 20,
                                  height: 20,
                                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MessageLine {
  final String id;
  final String author;
  final String text;
  final bool fromMe;

  const _MessageLine({
    this.id = '',
    required this.author,
    required this.text,
    required this.fromMe,
  });
}
