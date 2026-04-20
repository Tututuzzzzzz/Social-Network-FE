import 'package:equatable/equatable.dart';

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

class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final List<MessageMediaEntity> media;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MessageEntity({
    required this.id,
    this.conversationId = '',
    this.senderId = '',
    this.content = '',
    this.media = const [],
    this.createdAt,
    this.updatedAt,
  });

  MessageEntity copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    List<MessageMediaEntity>? media,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      media: media ?? this.media,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    content,
    media,
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
