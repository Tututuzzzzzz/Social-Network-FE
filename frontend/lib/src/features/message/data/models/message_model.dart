import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    super.conversationId,
    super.senderId,
    super.senderName,
    super.senderAvatarUrl,
    super.content,
    super.media,
    super.reactions,
    super.readBy,
    super.createdAt,
    super.updatedAt,
  });

  factory MessageModel.fromJson(dynamic json) {
    if (json is! Map) {
      return const MessageModel(id: '');
    }

    final map = Map<String, dynamic>.from(json);
    final rawMedia = map['media'];
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

    final rawReadBy = map['readBy'];
    final readByItems = <MessageReadByEntity>[];

    if (rawReadBy is List) {
      for (final item in rawReadBy) {
        if (item is! Map) continue;
        final rMap = Map<String, dynamic>.from(item);

        final rUser = rMap['userId'];
        String rUserId = '';
        String rDisplayName = '';
        String rAvatarUrl = '';

        if (rUser is Map) {
          final uMap = Map<String, dynamic>.from(rUser);
          rUserId = (uMap['_id'] ?? uMap['id'] ?? '').toString();
          rDisplayName =
              uMap['displayName']?.toString() ?? uMap['name']?.toString() ?? '';
          rAvatarUrl =
              uMap['avatarUrl']?.toString() ?? uMap['avatar']?.toString() ?? '';
        } else {
          rUserId = rUser?.toString() ?? '';
        }

        readByItems.add(
          MessageReadByEntity(
            userId: rUserId,
            displayName: rDisplayName,
            avatarUrl: rAvatarUrl,
            readAt: DateTime.tryParse(rMap['readAt']?.toString() ?? ''),
          ),
        );
      }
    }

    final conversationRaw = map['conversationId'];
    String conversationId = '';
    if (conversationRaw is Map) {
      conversationId = (conversationRaw['_id'] ?? conversationRaw['id'] ?? '')
          .toString();
    } else {
      conversationId = conversationRaw?.toString() ?? '';
    }

    final senderRaw = map['senderId'];
    String senderId = '';
    String senderName = map['senderName']?.toString() ?? '';
    String senderAvatarUrl =
        map['senderAvatarUrl']?.toString() ??
        map['senderAvatar']?.toString() ??
        '';
    if (senderRaw is Map) {
      senderId = (senderRaw['_id'] ?? senderRaw['id'] ?? '').toString();
      final senderMap = Map<String, dynamic>.from(senderRaw);
      senderName =
          senderMap['displayName']?.toString() ??
          senderMap['name']?.toString() ??
          senderMap['fullName']?.toString() ??
          senderMap['username']?.toString() ??
          senderMap['senderName']?.toString() ??
          senderName;
      senderAvatarUrl =
          senderMap['avatarUrl']?.toString() ??
          senderMap['avatar']?.toString() ??
          senderMap['photo']?.toString() ??
          senderMap['photoUrl']?.toString() ??
          senderMap['profilePicture']?.toString() ??
          senderMap['profilePictureUrl']?.toString() ??
          senderAvatarUrl;
    } else {
      senderId = senderRaw?.toString() ?? '';
    }

    final rawReactions = map['reactions'];
    final reactionItems = <MessageReactionEntity>[];
    if (rawReactions is List) {
      for (final item in rawReactions) {
        if (item is! Map) continue;
        final rMap = Map<String, dynamic>.from(item);

        final reactedUserId = rMap['userId'];
        String userId = '';
        if (reactedUserId is Map) {
          userId = (reactedUserId['_id'] ?? reactedUserId['id'] ?? '')
              .toString();
        } else {
          userId = reactedUserId?.toString() ?? '';
        }

        reactionItems.add(
          MessageReactionEntity(
            userId: userId,
            emoji: rMap['emoji']?.toString() ?? '',
            reactedAt: DateTime.tryParse(rMap['reactedAt']?.toString() ?? ''),
          ),
        );
      }
    }

    return MessageModel(
      id: (map['_id'] ?? map['id'] ?? '').toString(),
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
      content: map['content']?.toString() ?? '',
      media: mediaItems,
      reactions: reactionItems,
      readBy: readByItems,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? ''),
    );
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      conversationId: entity.conversationId,
      senderId: entity.senderId,
      senderName: entity.senderName,
      senderAvatarUrl: entity.senderAvatarUrl,
      content: entity.content,
      media: entity.media,
      reactions: entity.reactions,
      readBy: entity.readBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversationId': conversationId,
    'senderId': senderId,
    'senderName': senderName,
    'senderAvatarUrl': senderAvatarUrl,
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
    'readBy': readBy
        .map(
          (item) => {
            // Serialize as a full object so fromJson can recover displayName & avatarUrl
            'userId': {
              '_id': item.userId,
              'displayName': item.displayName,
              'avatarUrl': item.avatarUrl,
            },
            'readAt': item.readAt?.toIso8601String(),
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
    final rawMessage = json['message'];

    return MessageActionResultModel(
      message: rawMessage is String ? rawMessage : '',
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : rawMessage is Map
          ? {'message': Map<String, dynamic>.from(rawMessage)}
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
