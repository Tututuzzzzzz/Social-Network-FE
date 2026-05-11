part of 'message_chat_room_page.dart';

mixin MessageChatRoomActions on State<MessageChatRoomPage> {
  ScrollController get historyScrollController;
  TextEditingController get composerController;
  ImagePicker get imagePicker;
  double get previousMaxScrollExtentBeforeOlderLoad;
  set previousMaxScrollExtentBeforeOlderLoad(double value);
  int get historyPageLimit;
  MessageChatRoomState? get previousChatState;
  set previousChatState(MessageChatRoomState? value);

  void onHistoryScroll() {
    if (!historyScrollController.hasClients) {
      return;
    }

    if (historyScrollController.position.pixels <= 80) {
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

    previousMaxScrollExtentBeforeOlderLoad = historyScrollController.hasClients
        ? historyScrollController.position.maxScrollExtent
        : 0.0;

    context.read<MessageBloc>().add(
      MessageHistoryLoadOlderRequested(
        conversationId: widget.thread.id,
        cursor: cursor,
        limit: historyPageLimit,
      ),
    );
  }

  void restoreScrollAfterOlderLoaded() {
    if (!historyScrollController.hasClients) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!historyScrollController.hasClients) {
        return;
      }

      final newMaxScrollExtent =
          historyScrollController.position.maxScrollExtent;
      final delta = newMaxScrollExtent - previousMaxScrollExtentBeforeOlderLoad;
      if (delta > 0) {
        historyScrollController.jumpTo(
          historyScrollController.position.pixels + delta,
        );
      }
    });
  }

  void scrollToLatestAfterHydration() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!historyScrollController.hasClients) {
        return;
      }

      final maxScrollExtent = historyScrollController.position.maxScrollExtent;
      historyScrollController.jumpTo(maxScrollExtent);
    });
  }

  void onSendPressed(BuildContext blocContext) {
    final text = composerController.text.trim();
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.unknownRecipient)));
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

  Future<void> onPickMediaPressed(ImageSource source) async {
    try {
      final image = await imagePicker.pickImage(
        source: source,
        imageQuality: 88,
      );
      if (image == null) {
        return;
      }

      final file = await _toUploadFile(image);
      if (!mounted) {
        return;
      }

      final content = composerController.text.trim();

      if (widget.thread.isGroup) {
        context.read<MessageBloc>().add(
          SendGroupMediaEvent(
            conversationId: widget.thread.id,
            files: [file],
            content: content.isEmpty ? null : content,
          ),
        );
        return;
      }

      final recipientId = widget.thread.recipientId.trim();
      if (recipientId.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.unknownRecipient)));
        return;
      }

      context.read<MessageBloc>().add(
        SendDirectMediaEvent(
          conversationId: widget.thread.id,
          recipientId: recipientId,
          files: [file],
          content: content.isEmpty ? null : content,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.messagePickMediaFailed)),
      );
    }
  }

  Future<MessageMediaUploadFile> _toUploadFile(XFile image) async {
    final bytes = kIsWeb ? await image.readAsBytes() : null;
    return MessageMediaUploadFile(
      name: image.name.trim().isEmpty ? 'message-image.jpg' : image.name,
      path: kIsWeb ? null : image.path,
      bytes: bytes,
      mimeType: image.mimeType,
    );
  }

  ChatEntity buildUpdatedThread(MessageChatRoomState? chatState) {
    final messages = chatState?.messages ?? const <MessageLine>[];
    final lastLine = messages.isNotEmpty ? messages.last : null;
    final lastMessage = lastLine == null
        ? ''
        : (lastLine.content.trim().isNotEmpty
              ? lastLine.content.trim()
              : (lastLine.media.isNotEmpty
                    ? context.l10n.attachmentLabel
                    : lastLine.text.trim()));
    final preview = lastMessage.isNotEmpty
        ? lastMessage
        : (widget.thread.messagePreview.trim().isNotEmpty
              ? widget.thread.messagePreview.trim()
              : context.l10n.startChatting);

    final fullConversation = messages
        .map((line) {
          final text = line.content.trim().isNotEmpty
              ? line.content.trim()
              : (line.media.isNotEmpty
                    ? context.l10n.attachmentLabel
                    : line.text);
          return '${line.author}: $text';
        })
        .join('\n');

    return widget.thread.copyWith(
      messagePreview: preview,
      timeLabel: context.l10n.timeNow,
      fullConversation: fullConversation,
      unreadCount: 0,
    );
  }

  String resolvePeerAvatarUrl(MessageChatRoomState? chatState) {
    if (widget.thread.isGroup) {
      return widget.thread.avatarUrl.trim();
    }

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

  void closeWithResult() {
    final currentState = context.read<MessageBloc>().state;
    final chatState = currentState is MessageChatRoomState
        ? currentState
        : previousChatState;
    Navigator.of(context).pop(buildUpdatedThread(chatState));
  }
}
