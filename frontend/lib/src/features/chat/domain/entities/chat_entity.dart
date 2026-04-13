import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final String id;
  final String senderName;
  final String messagePreview;
  final String timeLabel;
  final int unreadCount;
  final bool isPinned;
  final bool isOnline;
  final bool isGroup;
  final String fullConversation;

  const ChatEntity({
    required this.id,
    this.senderName = '',
    this.messagePreview = '',
    this.timeLabel = '',
    this.unreadCount = 0,
    this.isPinned = false,
    this.isOnline = false,
    this.isGroup = false,
    this.fullConversation = '',
  });

  @override
  List<Object?> get props => [
    id,
    senderName,
    messagePreview,
    timeLabel,
    unreadCount,
    isPinned,
    isOnline,
    isGroup,
    fullConversation,
  ];
}
