import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final String id;
  final String recipientId;
  final String senderName;
  final String messagePreview;
  final String timeLabel;
  final int unreadCount;
  final bool isPinned;
  final bool isHidden;
  final bool isOnline;
  final bool isGroup;
  final String fullConversation;

  const ChatEntity({
    required this.id,
    this.recipientId = '',
    this.senderName = '',
    this.messagePreview = '',
    this.timeLabel = '',
    this.unreadCount = 0,
    this.isPinned = false,
    this.isHidden = false,
    this.isOnline = false,
    this.isGroup = false,
    this.fullConversation = '',
  });

  ChatEntity copyWith({
    String? id,
    String? recipientId,
    String? senderName,
    String? messagePreview,
    String? timeLabel,
    int? unreadCount,
    bool? isPinned,
    bool? isHidden,
    bool? isOnline,
    bool? isGroup,
    String? fullConversation,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      senderName: senderName ?? this.senderName,
      messagePreview: messagePreview ?? this.messagePreview,
      timeLabel: timeLabel ?? this.timeLabel,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isHidden: isHidden ?? this.isHidden,
      isOnline: isOnline ?? this.isOnline,
      isGroup: isGroup ?? this.isGroup,
      fullConversation: fullConversation ?? this.fullConversation,
    );
  }

  @override
  List<Object?> get props => [
    id,
    recipientId,
    senderName,
    messagePreview,
    timeLabel,
    unreadCount,
    isPinned,
    isHidden,
    isOnline,
    isGroup,
    fullConversation,
  ];
}
