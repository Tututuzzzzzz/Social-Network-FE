import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    super.conversationId,
    super.senderId,
    super.content,
    super.media,
    super.createdAt,
    super.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final rawMedia = json['media'];
    final mediaItems = <MessageMediaEntity>[];

    if (rawMedia is List) {
      for (final item in rawMedia) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        mediaItems.add(
          MessageMediaEntity(
            bucket: map['bucket']?.toString() ?? '',
            objectKey: map['objectKey']?.toString() ?? '',
            mimeType: map['mimeType']?.toString() ?? '',
            size: (map['size'] as num?)?.toInt() ?? 0,
            mediaUrl: map['mediaUrl']?.toString() ?? '',
          ),
        );
      }
    }

    final conversationRaw = json['conversationId'];
    String conversationId = '';
    if (conversationRaw is Map) {
      conversationId = (conversationRaw['_id'] ?? conversationRaw['id'] ?? '')
          .toString();
    } else {
      conversationId = conversationRaw?.toString() ?? '';
    }

    final senderRaw = json['senderId'];
    String senderId = '';
    if (senderRaw is Map) {
      senderId = (senderRaw['_id'] ?? senderRaw['id'] ?? '').toString();
    } else {
      senderId = senderRaw?.toString() ?? '';
    }

    return MessageModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      conversationId: conversationId,
      senderId: senderId,
      content: json['content']?.toString() ?? '',
      media: mediaItems,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}

class MessageActionResultModel extends MessageActionResultEntity {
  const MessageActionResultModel({super.message, super.data});

  factory MessageActionResultModel.fromJson(Map<String, dynamic> json) {
    return MessageActionResultModel(
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : null,
    );
  }
}
