import 'package:flutter/material.dart';

import '../../domain/entities/chat_entity.dart';

class MochiChatRoomPage extends StatefulWidget {
  final ChatEntity thread;

  const MochiChatRoomPage({super.key, required this.thread});

  @override
  State<MochiChatRoomPage> createState() => _MochiChatRoomPageState();
}

class _MochiChatRoomPageState extends State<MochiChatRoomPage> {
  final TextEditingController _composerController = TextEditingController();
  final List<_MessageLine> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.addAll(_parseConversation(widget.thread));
  }

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
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

  void _sendMessage() {
    final text = _composerController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(_MessageLine(author: 'You', text: text, fromMe: true));
      _composerController.clear();
    });
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
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
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
                        onSubmitted: (_) => _sendMessage(),
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
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageLine {
  final String author;
  final String text;
  final bool fromMe;

  const _MessageLine({
    required this.author,
    required this.text,
    required this.fromMe,
  });
}
