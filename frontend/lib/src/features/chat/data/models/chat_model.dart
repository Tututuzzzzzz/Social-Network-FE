import '../../domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    super.senderName,
    super.messagePreview,
    super.timeLabel,
    super.unreadCount,
    super.isPinned,
    super.isHidden,
    super.isOnline,
    super.isGroup,
    super.fullConversation,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      messagePreview: json['messagePreview']?.toString() ?? '',
      timeLabel: json['timeLabel']?.toString() ?? '',
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isPinned: json['isPinned'] == true,
      isHidden: json['isHidden'] == true,
      isOnline: json['isOnline'] == true,
      isGroup: json['isGroup'] == true,
      fullConversation: json['fullConversation']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderName': senderName,
    'messagePreview': messagePreview,
    'timeLabel': timeLabel,
    'unreadCount': unreadCount,
    'isPinned': isPinned,
    'isHidden': isHidden,
    'isOnline': isOnline,
    'isGroup': isGroup,
    'fullConversation': fullConversation,
  };
}
