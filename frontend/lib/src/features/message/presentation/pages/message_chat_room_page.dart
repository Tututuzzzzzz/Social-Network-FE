import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../chat/domain/entities/chat_entity.dart';
import '../bloc/message_bloc.dart';
import '../bloc/message_event.dart';
import '../bloc/message_state.dart';
import '../widgets/message_chat_room_app_bar.dart';
import '../widgets/message_composer.dart';
import '../widgets/message_history_list.dart';

class MessageChatRoomPage extends StatefulWidget {
  final ChatEntity thread;

  const MessageChatRoomPage({super.key, required this.thread});

  @override
  State<MessageChatRoomPage> createState() => _MessageChatRoomPageState();
}

class _MessageChatRoomPageState extends State<MessageChatRoomPage> {
  static const Color _accentGreen = Color(0xFF3CC18E);
  static const Color _pageBackground = Color(0xFFF7F8FA);
  static const Color _peerBubble = Color(0xFFF2F4F7);
  static const Color _composerFill = Color(0xFFF3F4F6);
  static const int _historyPageLimit = 30;

  final TextEditingController _composerController = TextEditingController();
  final ScrollController _historyScrollController = ScrollController();
  double _previousMaxScrollExtentBeforeOlderLoad = 0.0;
  MessageChatRoomState? _previousChatState;

  @override
  void initState() {
    super.initState();
    _historyScrollController.addListener(_onHistoryScroll);
    context.read<MessageBloc>().add(
      MessageChatRoomStarted(thread: widget.thread, limit: _historyPageLimit),
    );
  }

  @override
  void dispose() {
    _historyScrollController
      ..removeListener(_onHistoryScroll)
      ..dispose();
    _composerController.dispose();
    super.dispose();
  }

  void _onHistoryScroll() {
    if (!_historyScrollController.hasClients) {
      return;
    }

    if (_historyScrollController.position.pixels <= 80) {
      _maybeLoadOlderHistory();
    }
  }

  void _maybeLoadOlderHistory() {
    final currentState = context.read<MessageBloc>().state;
    if (currentState is! MessageChatRoomState) {
      return;
    }

    final cursor = currentState.nextCursor?.trim();
    if (currentState.isLoadingOlderHistory ||
        !currentState.hasMoreHistory ||
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

  void _onSendPressed(BuildContext blocContext) {
    final text = _composerController.text.trim();
    if (text.isEmpty) {
      return;
    }

    if (widget.thread.isGroup) {
      blocContext.read<MessageBloc>().add(
        SendGroupTextEvent(conversationId: widget.thread.id, content: text),
      );
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

  ChatEntity _buildUpdatedThread(MessageChatRoomState? chatState) {
    final messages = chatState?.messages ?? const <MessageLine>[];
    final lastMessage = messages.isNotEmpty ? messages.last.text.trim() : '';
    final preview = lastMessage.isNotEmpty
        ? lastMessage
        : (widget.thread.messagePreview.trim().isNotEmpty
              ? widget.thread.messagePreview.trim()
              : 'Start chatting...');

    final fullConversation = messages
        .map((line) => '${line.author}: ${line.text}')
        .join('\n');

    return widget.thread.copyWith(
      messagePreview: preview,
      timeLabel: 'now',
      fullConversation: fullConversation,
      unreadCount: 0,
    );
  }

  String _resolvePeerAvatarUrl(MessageChatRoomState? chatState) {
    final messages = chatState?.messages ?? const <MessageLine>[];

    for (var index = messages.length - 1; index >= 0; index -= 1) {
      final line = messages[index];
      final avatarUrl = line.senderAvatarUrl.trim();
      if (!line.fromMe && avatarUrl.isNotEmpty) {
        return avatarUrl;
      }
    }

    return widget.thread.avatarUrl.trim();
  }

  void _closeWithResult() {
    final currentState = context.read<MessageBloc>().state;
    final chatState = currentState is MessageChatRoomState
        ? currentState
        : _previousChatState;
    Navigator.of(context).pop(_buildUpdatedThread(chatState));
  }

  @override
  Widget build(BuildContext context) {
    final threadName = widget.thread.senderName.trim().isEmpty
        ? 'Conversation'
        : widget.thread.senderName.trim();
    final currentState = context.watch<MessageBloc>().state;
    final chatState = currentState is MessageChatRoomState
        ? currentState
        : _previousChatState;
    final threadAvatarUrl = _resolvePeerAvatarUrl(chatState);

    return PopScope<ChatEntity>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _closeWithResult();
      },
      child: Scaffold(
        backgroundColor: _pageBackground,
        appBar: MessageChatRoomAppBar(
          title: threadName,
          avatarUrl: threadAvatarUrl,
          accentColor: _accentGreen,
          onBack: _closeWithResult,
        ),
        body: BlocConsumer<MessageBloc, MessageState>(
          listener: (context, state) {
            if (state is! MessageChatRoomState) {
              return;
            }

            final previous = _previousChatState;
            final previousErrorVersion = previous?.errorVersion ?? -1;
            final previousScrollToLatestVersion =
                previous?.scrollToLatestVersion ?? -1;
            final previousRestoreScrollVersion =
                previous?.restoreScrollVersion ?? -1;

            if (state.errorMessage != null &&
                state.errorVersion != previousErrorVersion) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }

            if (state.scrollToLatestVersion != previousScrollToLatestVersion) {
              if (state.scrollToLatestVersion > 0) {
                _scrollToLatestAfterHydration();
              }
            }

            if (state.restoreScrollVersion != previousRestoreScrollVersion) {
              if (state.restoreScrollVersion > 0) {
                _restoreScrollAfterOlderLoaded();
              }
            }

            if ((previous?.isSending ?? false) &&
                !state.isSending &&
                state.errorVersion == previousErrorVersion) {
              _composerController.clear();
            }

            _previousChatState = state;
          },
          builder: (blocContext, state) {
            final chatState = state is MessageChatRoomState
                ? state
                : MessageChatRoomState.initial();
            final isSending = chatState.isSending;

            return SafeArea(
              child: Column(
                children: [
                  if (chatState.isBootstrappingHistory)
                    const LinearProgressIndicator(minHeight: 2),
                  if (chatState.isLoadingOlderHistory)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  Expanded(
                    child: MessageHistoryList(
                      controller: _historyScrollController,
                      messages: chatState.messages,
                      accentColor: _accentGreen,
                      peerBubbleColor: _peerBubble,
                    ),
                  ),
                  MessageComposer(
                    controller: _composerController,
                    onSend: () => _onSendPressed(blocContext),
                    isSending: isSending,
                    accentColor: _accentGreen,
                    fillColor: _composerFill,
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
