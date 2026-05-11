import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';

import '../../../../core/utils/url_normalizer.dart';
import '../../domain/entities/message_entity.dart';
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
    this.isGroupChat = false,
    this.currentUserId = '',
    this.onReaction,
    this.onDelete,
  });

  final ScrollController controller;
  final List<MessageLine> messages;
  final Color accentColor;
  final Color peerBubbleColor;
  final bool isGroupChat;
  final String currentUserId;

  /// Called when a reaction should be added or removed.
  /// `isRemove` is true when the current user is toggling off their own reaction.
  final void Function(String messageId, String emoji, bool isRemove)?
  onReaction;

  /// Called when the user wants to delete their own message.
  final void Function(String messageId)? onDelete;

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(context, messages);

    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
      itemCount: items.length,
      separatorBuilder: (_, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final item = items[index];

        if (item.isHeader) {
          return _DateHeader(label: item.header!);
        }

        final message = item.message!;
        final showAvatar = item.showAvatar && !message.fromMe;
        final showAuthorName = item.showAuthorName && !message.fromMe;

        final avatar = _AvatarSlot(
          showAvatar: showAvatar,
          avatarUrl: message.senderAvatarUrl,
          label: message.author,
        );

        final bubble = _MessageBubbleWithReactions(
          message: message,
          accentColor: accentColor,
          peerBubbleColor: peerBubbleColor,
          isGroupChat: isGroupChat,
          currentUserId: currentUserId,
          onReaction: onReaction,
          onDelete: onDelete,
        );

        return Align(
          alignment: message.fromMe
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: message.fromMe
              ? bubble
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showAuthorName)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: _avatarSize + _avatarGap + 4,
                          bottom: 4,
                        ),
                        child: Text(
                          message.author.trim().isNotEmpty
                              ? message.author.trim()
                              : context.l10n.unknownSenderLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        avatar,
                        const SizedBox(width: _avatarGap),
                        Flexible(child: bubble),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }

  List<_MessageListItem> _buildItems(
    BuildContext context,
    List<MessageLine> messages,
  ) {
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
          items.add(
            _MessageListItem.header(_formatDateLabel(context, createdAt)),
          );
          lastDate = dateOnly;
        }
      }

      items.add(
        _MessageListItem.message(
          message,
          showAvatar: _shouldShowAvatar(index, messages),
          showAuthorName: _shouldShowAuthorName(index, messages),
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

  bool _shouldShowAuthorName(int index, List<MessageLine> messages) {
    if (index == 0) {
      return true;
    }

    final current = messages[index];
    final prev = messages[index - 1];

    final sameSender = _isSameSender(current, prev);
    final sameDay = _isSameDay(current.createdAt, prev.createdAt);
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

  String _formatDateLabel(BuildContext context, DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    final target = DateUtils.dateOnly(date);
    if (DateUtils.isSameDay(today, target)) {
      return context.l10n.todayLabel;
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
  final bool showAuthorName;

  const _MessageListItem._({
    this.message,
    this.header,
    this.showAvatar = false,
    this.showAuthorName = false,
  });

  factory _MessageListItem.message(
    MessageLine message, {
    required bool showAvatar,
    required bool showAuthorName,
  }) {
    return _MessageListItem._(
      message: message,
      showAvatar: showAvatar,
      showAuthorName: showAuthorName,
    );
  }

  factory _MessageListItem.header(String header) {
    return _MessageListItem._(header: header);
  }

  bool get isHeader => header != null;
}

class _MessageBubbleWithReactions extends StatefulWidget {
  const _MessageBubbleWithReactions({
    required this.message,
    required this.accentColor,
    required this.peerBubbleColor,
    required this.isGroupChat,
    required this.currentUserId,
    this.onReaction,
    this.onDelete,
  });

  final MessageLine message;
  final Color accentColor;
  final Color peerBubbleColor;
  final bool isGroupChat;
  final String currentUserId;
  final void Function(String messageId, String emoji, bool isRemove)?
  onReaction;
  final void Function(String messageId)? onDelete;

  @override
  State<_MessageBubbleWithReactions> createState() =>
      _MessageBubbleWithReactionsState();
}

class _MessageBubbleWithReactionsState
    extends State<_MessageBubbleWithReactions> {
  static const List<String> _emojiSet = ['😀', '😍', '😂', '🔥', '👍', '❤️'];

  void _showReactionPicker(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final bubbleSize = renderBox.size;
    final bubblePosition = renderBox.localToGlobal(Offset.zero);

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (overlayContext) {
        // Position the emoji bar above the bubble
        final screenWidth = MediaQuery.of(overlayContext).size.width;
        final bool showDelete =
            widget.message.fromMe && !widget.message.isDeleted;
        final barWidth = showDelete ? 310.0 : 260.0;
        const barHeight = 48.0;

        // Calculate X — center relative to bubble, clamp to screen edges
        double left =
            bubblePosition.dx + (bubbleSize.width / 2) - (barWidth / 2);
        if (left < 8) left = 8;
        if (left + barWidth > screenWidth - 8) {
          left = screenWidth - barWidth - 8;
        }

        // Calculate Y — above the bubble
        double top = bubblePosition.dy - barHeight - 8;
        if (top < 40) top = bubblePosition.dy + bubbleSize.height + 8;

        return Stack(
          children: [
            // Transparent barrier to dismiss on tap outside
            Positioned.fill(
              child: GestureDetector(
                onTap: () => entry.remove(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: _FloatingActionBar(
                emojis: _emojiSet,
                showDelete: widget.message.fromMe && !widget.message.isDeleted,
                onEmojiSelected: (emoji) {
                  entry.remove();
                  widget.onReaction?.call(widget.message.id, emoji, false);
                },
                onDelete: () {
                  entry.remove();
                  widget.onDelete?.call(widget.message.id);
                },
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(entry);
  }

  /// Check if the current user has reacted with the given emoji.
  bool _hasUserReacted(String emoji) {
    if (widget.currentUserId.isEmpty) return false;
    for (final reaction in widget.message.reactions) {
      final rEmoji = reaction['emoji']?.toString() ?? '';
      final rUserId = reaction['userId']?.toString() ?? '';
      if (rEmoji == emoji && rUserId == widget.currentUserId) {
        return true;
      }
    }
    return false;
  }

  void _onReactionChipTapped(String emoji) {
    final isRemove = _hasUserReacted(emoji);
    widget.onReaction?.call(widget.message.id, emoji, isRemove);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDeleted = widget.message.isDeleted;

    return GestureDetector(
      onLongPress: isDeleted ? null : () => _showReactionPicker(context),
      child: Column(
        crossAxisAlignment: widget.message.fromMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          _MessageBubble(
            message: widget.message,
            accentColor: widget.accentColor,
            peerBubbleColor: widget.peerBubbleColor,
            isGroupChat: widget.isGroupChat,
          ),
          if (!isDeleted && widget.message.reactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _ReactionsDisplay(
                reactions: widget.message.reactions,
                maxWidth: 200,
                currentUserId: widget.currentUserId,
                onReactionTapped: _onReactionChipTapped,
              ),
            ),
          if (widget.message.readBy.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: widget.isGroupChat
                  ? _buildGroupReadReceipts(widget.message.readBy)
                  : _build1to1ReadReceipt(),
            ),
        ],
      ),
    );
  }

  Widget _build1to1ReadReceipt() {
    return const Text(
      'Đã xem',
      style: TextStyle(
        fontSize: 11,
        color: Color(0xFF9CA3AF),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildGroupReadReceipts(List<MessageReadByEntity> readBy) {
    const maxAvatars = 5;
    final displayUsers = readBy.take(maxAvatars).toList();
    final overflow = readBy.length - maxAvatars;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (var i = 0; i < displayUsers.length; i++)
          Align(
            widthFactor: 0.6,
            child: CircleAvatar(
              radius: 9,
              backgroundColor: Colors.white,
              child: _MiniAvatar(
                avatarUrl: displayUsers[i].avatarUrl,
                label: displayUsers[i].displayName,
              ),
            ),
          ),
        if (overflow > 0)
          Align(
            widthFactor: 0.6,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              child: Text(
                '+$overflow',
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Floating action bar shown on long-press.
/// A polished, rounded container with shadow that shows 6 emoji choices and an optional delete button.
class _FloatingActionBar extends StatelessWidget {
  const _FloatingActionBar({
    required this.emojis,
    required this.onEmojiSelected,
    this.showDelete = false,
    this.onDelete,
  });

  final List<String> emojis;
  final void Function(String emoji) onEmojiSelected;
  final bool showDelete;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(28),
      shadowColor: Colors.black26,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...emojis.map((emoji) {
              return _EmojiButton(
                emoji: emoji,
                onTap: () => onEmojiSelected(emoji),
              );
            }),
            if (showDelete) ...[
              Container(
                width: 1,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: const Color(0xFFE5E7EB),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmojiButton extends StatefulWidget {
  const _EmojiButton({required this.emoji, required this.onTap});

  final String emoji;
  final VoidCallback onTap;

  @override
  State<_EmojiButton> createState() => _EmojiButtonState();
}

class _EmojiButtonState extends State<_EmojiButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.35,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(widget.emoji, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.accentColor,
    required this.peerBubbleColor,
    required this.isGroupChat,
  });

  final MessageLine message;
  final Color accentColor;
  final Color peerBubbleColor;
  final bool isGroupChat;

  @override
  Widget build(BuildContext context) {
    final mediaUrls = message.media
        .map((item) => item.mediaUrl.normalizeClientUrl())
        .where((url) => url.isNotEmpty)
        .toList();

    final displayStyle = message.isDeleted
        ? TextStyle(
            height: 1.32,
            color:
                (message.fromMe ? accentColor : peerBubbleColor) == accentColor
                ? Colors.white70
                : const Color(0xFF6B7280),
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
          )
        : TextStyle(
            height: 1.32,
            color: message.fromMe ? Colors.white : const Color(0xFF2E3138),
            fontWeight: FontWeight.w500,
          );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 270),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: message.isDeleted
              ? (message.fromMe
                    ? accentColor.withValues(alpha: 0.5)
                    : peerBubbleColor.withValues(alpha: 0.5))
              : (message.fromMe ? accentColor : peerBubbleColor),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.fromMe ? 16 : 4),
            bottomRight: Radius.circular(message.fromMe ? 4 : 16),
          ),
        ),
        child: message.isDeleted
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.block, size: 14, color: displayStyle.color),
                    const SizedBox(width: 6),
                    Text(context.l10n.deletedMessageLabel, style: displayStyle),
                  ],
                ),
              )
            : _BubbleContent(
                message: message,
                mediaUrls: mediaUrls,
                textStyle: displayStyle,
              ),
      ),
    );
  }
}

class _BubbleContent extends StatelessWidget {
  const _BubbleContent({
    required this.message,
    required this.mediaUrls,
    required this.textStyle,
  });

  final MessageLine message;
  final List<String> mediaUrls;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final hasText = message.content.trim().isNotEmpty;

    if (mediaUrls.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(message.text, style: textStyle),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < mediaUrls.length; index += 1) ...[
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(
                hasText || index < mediaUrls.length - 1 ? 4 : 16,
              ),
              bottomRight: Radius.circular(
                hasText || index < mediaUrls.length - 1 ? 4 : 16,
              ),
            ),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(
                mediaUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: Color(0xFFE5E7EB),
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (index < mediaUrls.length - 1) const SizedBox(height: 2),
        ],
        if (hasText)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(message.content, style: textStyle),
          ),
      ],
    );
  }
}

class _ReactionsDisplay extends StatelessWidget {
  final List<Map<String, dynamic>> reactions;
  final double maxWidth;
  final String currentUserId;
  final void Function(String emoji)? onReactionTapped;

  const _ReactionsDisplay({
    required this.reactions,
    required this.maxWidth,
    this.currentUserId = '',
    this.onReactionTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Group reactions by emoji and count them
    final reactionCounts = <String, int>{};
    final userReactedEmojis = <String>{};

    for (final reaction in reactions) {
      final emoji = reaction['emoji']?.toString() ?? '';
      final userId = reaction['userId']?.toString() ?? '';
      if (emoji.isNotEmpty) {
        reactionCounts[emoji] = (reactionCounts[emoji] ?? 0) + 1;
        if (currentUserId.isNotEmpty && userId == currentUserId) {
          userReactedEmojis.add(emoji);
        }
      }
    }

    if (reactionCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 4,
      children: reactionCounts.entries.map((entry) {
        final isHighlighted = userReactedEmojis.contains(entry.key);

        return GestureDetector(
          onTap: () => onReactionTapped?.call(entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: isHighlighted
                    ? const Color(0xFF3CC18E)
                    : const Color(0xFFD1D5DB),
                width: isHighlighted ? 1.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isHighlighted
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFFAFAFA),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(entry.key, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 2),
                Text(
                  entry.value.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: isHighlighted
                        ? const Color(0xFF059669)
                        : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  final String avatarUrl;
  final String label;

  const _MiniAvatar({required this.avatarUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    final trimmedLabel = label.trim();
    final initial = trimmedLabel.isNotEmpty
        ? trimmedLabel.substring(0, 1).toUpperCase()
        : '?';
    final normalizedUrl = avatarUrl.normalizeClientUrl();

    return CircleAvatar(
      radius: 8,
      backgroundColor: const Color(0xFFD1D5DB),
      backgroundImage: normalizedUrl.isNotEmpty
          ? NetworkImage(normalizedUrl)
          : null,
      child: normalizedUrl.isNotEmpty
          ? null
          : Text(
              initial,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
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

    final normalizedAvatarUrl = avatarUrl.normalizeClientUrl();

    return CircleAvatar(
      radius: MessageHistoryList._avatarSize / 2,
      backgroundColor: const Color(0xFFD1D5DB),
      backgroundImage: normalizedAvatarUrl.isNotEmpty
          ? NetworkImage(normalizedAvatarUrl)
          : null,
      child: normalizedAvatarUrl.isNotEmpty
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
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
