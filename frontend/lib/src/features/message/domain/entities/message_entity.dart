import 'package:equatable/equatable.dart';

class MessageReadByEntity extends Equatable {
  final String userId;
  final String displayName;
  final String avatarUrl;
  final DateTime? readAt;

  const MessageReadByEntity({
    required this.userId,
    this.displayName = '',
    this.avatarUrl = '',
    this.readAt,
  });

  @override
  List<Object?> get props => [userId, displayName, avatarUrl, readAt];
}

class MessageMediaEntity extends Equatable {
  final String bucket;
  final String objectKey;
  final String mimeType;
  final int size;
  final String mediaUrl;

  const MessageMediaEntity({
    this.bucket = '',
    this.objectKey = '',
    this.mimeType = '',
    this.size = 0,
    this.mediaUrl = '',
  });

  @override
  List<Object?> get props => [bucket, objectKey, mimeType, size, mediaUrl];
}

class MessageReactionEntity extends Equatable {
  final String userId;
  final String emoji;
  final DateTime? reactedAt;

  const MessageReactionEntity({
    required this.userId,
    required this.emoji,
    this.reactedAt,
  });

  @override
  List<Object?> get props => [userId, emoji, reactedAt];
}

class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderAvatarUrl;
  final String content;
  final List<MessageMediaEntity> media;
  final List<MessageReactionEntity> reactions;
  final List<MessageReadByEntity> readBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MessageEntity({
    required this.id,
    this.conversationId = '',
    this.senderId = '',
    this.senderName = '',
    this.senderAvatarUrl = '',
    this.content = '',
    this.media = const [],
    this.reactions = const [],
    this.readBy = const [],
    this.createdAt,
    this.updatedAt,
  });

  MessageEntity copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? content,
    List<MessageMediaEntity>? media,
    List<MessageReactionEntity>? reactions,
    List<MessageReadByEntity>? readBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      content: content ?? this.content,
      media: media ?? this.media,
      reactions: reactions ?? this.reactions,
      readBy: readBy ?? this.readBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    senderName,
    senderAvatarUrl,
    content,
    media,
    reactions,
    readBy,
    createdAt,
    updatedAt,
  ];
}

class MessageActionResultEntity extends Equatable {
  final String message;
  final Map<String, dynamic>? data;

  const MessageActionResultEntity({this.message = '', this.data});

  @override
  List<Object?> get props => [message, data];
}

class MessageHistoryPageEntity extends Equatable {
  final List<MessageEntity> messages;
  final bool hasMore;
  final int limit;
  final String? nextCursor;

  const MessageHistoryPageEntity({
    this.messages = const [],
    this.hasMore = false,
    this.limit = 30,
    this.nextCursor,
  });

  MessageHistoryPageEntity copyWith({
    List<MessageEntity>? messages,
    bool? hasMore,
    int? limit,
    String? nextCursor,
  }) {
    return MessageHistoryPageEntity(
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      limit: limit ?? this.limit,
      nextCursor: nextCursor ?? this.nextCursor,
    );
  }

  @override
  List<Object?> get props => [messages, hasMore, limit, nextCursor];
}
