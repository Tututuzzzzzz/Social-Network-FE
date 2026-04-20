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

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      conversationId: entity.conversationId,
      senderId: entity.senderId,
      content: entity.content,
      media: entity.media,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversationId': conversationId,
    'senderId': senderId,
    'content': content,
    'media': media
        .map(
          (item) => {
            'bucket': item.bucket,
            'objectKey': item.objectKey,
            'mimeType': item.mimeType,
            'size': item.size,
            'mediaUrl': item.mediaUrl,
          },
        )
        .toList(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
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

class MessageHistoryPageModel extends MessageHistoryPageEntity {
  const MessageHistoryPageModel({
    super.messages,
    super.hasMore,
    super.limit,
    super.nextCursor,
  });

  factory MessageHistoryPageModel.fromApiJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    final messages = <MessageEntity>[];

    if (dataRaw is List) {
      for (final item in dataRaw) {
        if (item is! Map) {
          continue;
        }

        messages.add(MessageModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    final pageInfoRaw = json['pageInfo'];
    final pageInfo = pageInfoRaw is Map
        ? Map<String, dynamic>.from(pageInfoRaw)
        : const <String, dynamic>{};

    return MessageHistoryPageModel(
      messages: messages,
      hasMore: pageInfo['hasMore'] == true,
      limit: (pageInfo['limit'] as num?)?.toInt() ?? 30,
      nextCursor: pageInfo['nextCursor']?.toString(),
    );
  }

  factory MessageHistoryPageModel.fromCacheJson(Map<String, dynamic> json) {
    final messagesRaw = json['messages'];
    final messages = <MessageEntity>[];

    if (messagesRaw is List) {
      for (final item in messagesRaw) {
        if (item is! Map) {
          continue;
        }

        messages.add(MessageModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return MessageHistoryPageModel(
      messages: messages,
      hasMore: json['hasMore'] == true,
      limit: (json['limit'] as num?)?.toInt() ?? 30,
      nextCursor: json['nextCursor']?.toString(),
    );
  }

  Map<String, dynamic> toCacheJson() => {
    'messages': messages
        .map((item) => MessageModel.fromEntity(item).toJson())
        .toList(),
    'hasMore': hasMore,
    'limit': limit,
    'nextCursor': nextCursor,
  };
}
