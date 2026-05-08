import 'package:flutter/material.dart';

import '../bloc/message_state.dart';

class MessageHistoryList extends StatelessWidget {
  static const double _avatarSize = 28;
  static const double _avatarGap = 8;

  const MessageHistoryList({
    super.key,
    required this.controller,
    required this.messages,
    required this.accentColor,
    required this.peerBubbleColor,
  });

  final ScrollController controller;
  final List<MessageLine> messages;
  final Color accentColor;
  final Color peerBubbleColor;

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(messages);

    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final item = items[index];

        if (item.isHeader) {
          return _DateHeader(label: item.header!);
        }

        final message = item.message!;
        final showAvatar = item.showAvatar;
        final avatar = _AvatarSlot(
          showAvatar: showAvatar,
          avatarUrl: message.senderAvatarUrl,
          label: message.author,
        );
        return Align(
          alignment: message.fromMe
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: message.fromMe
                ? [
                    _MessageBubble(
                      message: message,
                      accentColor: accentColor,
                      peerBubbleColor: peerBubbleColor,
                    ),
                    const SizedBox(width: _avatarGap),
                    avatar,
                  ]
                : [
                    avatar,
                    const SizedBox(width: _avatarGap),
                    _MessageBubble(
                      message: message,
                      accentColor: accentColor,
                      peerBubbleColor: peerBubbleColor,
                    ),
                  ],
          ),
        );
      },
    );
  }

  List<_MessageListItem> _buildItems(List<MessageLine> messages) {
    final items = <_MessageListItem>[];
    DateTime? lastDate;

    for (var index = 0; index < messages.length; index += 1) {
      final message = messages[index];
      final createdAt = message.createdAt?.toLocal();
      if (createdAt != null) {
        final dateOnly = DateUtils.dateOnly(createdAt);
        final shouldInsertHeader =
            lastDate == null || !DateUtils.isSameDay(dateOnly, lastDate);
        if (shouldInsertHeader) {
          items.add(_MessageListItem.header(_formatDateLabel(createdAt)));
          lastDate = dateOnly;
        }
      }

      items.add(
        _MessageListItem.message(
          message,
          showAvatar: _shouldShowAvatar(index, messages),
        ),
      );
    }

    return items;
  }

  bool _shouldShowAvatar(int index, List<MessageLine> messages) {
    if (index >= messages.length - 1) {
      return true;
    }

    final current = messages[index];
    final next = messages[index + 1];

    final sameSender = _isSameSender(current, next);
    final sameDay = _isSameDay(current.createdAt, next.createdAt);
    return !(sameSender && sameDay);
  }

  bool _isSameSender(MessageLine current, MessageLine next) {
    final currentSender = current.senderId.trim();
    final nextSender = next.senderId.trim();
    if (currentSender.isNotEmpty && nextSender.isNotEmpty) {
      return currentSender == nextSender;
    }

    if (current.fromMe != next.fromMe) {
      return false;
    }

    final currentAuthor = current.author.trim();
    final nextAuthor = next.author.trim();
    if (currentAuthor.isNotEmpty && nextAuthor.isNotEmpty) {
      return currentAuthor == nextAuthor;
    }

    return current.fromMe == next.fromMe;
  }

  bool _isSameDay(DateTime? current, DateTime? next) {
    if (current == null || next == null) {
      return true;
    }

    return DateUtils.isSameDay(current, next);
  }

  String _formatDateLabel(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    final target = DateUtils.dateOnly(date);
    if (DateUtils.isSameDay(today, target)) {
      return 'Hom nay';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}

class _MessageListItem {
  final MessageLine? message;
  final String? header;
  final bool showAvatar;

  const _MessageListItem._({
    this.message,
    this.header,
    this.showAvatar = false,
  });

  factory _MessageListItem.message(
    MessageLine message, {
    required bool showAvatar,
  }) {
    return _MessageListItem._(message: message, showAvatar: showAvatar);
  }

  factory _MessageListItem.header(String header) {
    return _MessageListItem._(header: header);
  }

  bool get isHeader => header != null;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.accentColor,
    required this.peerBubbleColor,
  });

  final MessageLine message;
  final Color accentColor;
  final Color peerBubbleColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 270),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: message.fromMe ? accentColor : peerBubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.fromMe ? 16 : 4),
            bottomRight: Radius.circular(message.fromMe ? 4 : 16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            message.text,
            style: TextStyle(
              height: 1.32,
              color: message.fromMe ? Colors.white : const Color(0xFF2E3138),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarSlot extends StatelessWidget {
  const _AvatarSlot({
    required this.showAvatar,
    required this.avatarUrl,
    required this.label,
  });

  final bool showAvatar;
  final String avatarUrl;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (!showAvatar) {
      return const SizedBox(
        width: MessageHistoryList._avatarSize,
        height: MessageHistoryList._avatarSize,
      );
    }

    final trimmedLabel = label.trim();
    final initial = trimmedLabel.isNotEmpty
        ? trimmedLabel.substring(0, 1).toUpperCase()
        : '?';

    return CircleAvatar(
      radius: MessageHistoryList._avatarSize / 2,
      backgroundColor: const Color(0xFFD1D5DB),
      backgroundImage: avatarUrl.trim().isNotEmpty
          ? NetworkImage(avatarUrl)
          : null,
      child: avatarUrl.trim().isNotEmpty
          ? null
          : Text(
              initial,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE9ECEF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
