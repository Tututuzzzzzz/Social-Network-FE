import 'package:equatable/equatable.dart';

import '../../domain/entities/message_entity.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {}

class MessageChatRoomState extends MessageState {
  final List<MessageLine> messages;
  final List<MessageEntity> messageEntities;
  final bool isBootstrappingHistory;
  final bool isLoadingOlderHistory;
  final bool isSending;
  final bool hasMoreHistory;
  final String? nextCursor;
  final String? errorMessage;
  final int errorVersion;
  final int scrollToLatestVersion;
  final int restoreScrollVersion;

  const MessageChatRoomState({
    required this.messages,
    required this.messageEntities,
    required this.isBootstrappingHistory,
    required this.isLoadingOlderHistory,
    required this.isSending,
    required this.hasMoreHistory,
    this.nextCursor,
    this.errorMessage,
    this.errorVersion = 0,
    this.scrollToLatestVersion = 0,
    this.restoreScrollVersion = 0,
  });

  factory MessageChatRoomState.initial() {
    return const MessageChatRoomState(
      messages: [],
      messageEntities: [],
      isBootstrappingHistory: false,
      isLoadingOlderHistory: false,
      isSending: false,
      hasMoreHistory: true,
    );
  }

  MessageChatRoomState copyWith({
    List<MessageLine>? messages,
    List<MessageEntity>? messageEntities,
    bool? isBootstrappingHistory,
    bool? isLoadingOlderHistory,
    bool? isSending,
    bool? hasMoreHistory,
    String? nextCursor,
    String? errorMessage,
    bool clearError = false,
    int? errorVersion,
    int? scrollToLatestVersion,
    int? restoreScrollVersion,
  }) {
    final resolvedErrorMessage = clearError
        ? null
        : (errorMessage ?? this.errorMessage);

    return MessageChatRoomState(
      messages: messages ?? this.messages,
      messageEntities: messageEntities ?? this.messageEntities,
      isBootstrappingHistory:
          isBootstrappingHistory ?? this.isBootstrappingHistory,
      isLoadingOlderHistory:
          isLoadingOlderHistory ?? this.isLoadingOlderHistory,
      isSending: isSending ?? this.isSending,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      nextCursor: nextCursor ?? this.nextCursor,
      errorMessage: resolvedErrorMessage,
      errorVersion: errorVersion ?? this.errorVersion,
      scrollToLatestVersion:
          scrollToLatestVersion ?? this.scrollToLatestVersion,
      restoreScrollVersion: restoreScrollVersion ?? this.restoreScrollVersion,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    messageEntities,
    isBootstrappingHistory,
    isLoadingOlderHistory,
    isSending,
    hasMoreHistory,
    nextCursor,
    errorMessage,
    errorVersion,
    scrollToLatestVersion,
    restoreScrollVersion,
  ];
}

class MessageSending extends MessageState {}

class MessageSent extends MessageState {
  final MessageEntity message;

  const MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageError extends MessageState {
  final String message;

  const MessageError(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageHistoryBootstrapping extends MessageState {}

class MessageHistoryBootstrapFinished extends MessageState {}

class MessageHistoryCacheHydrated extends MessageState {
  final MessageHistoryPageEntity page;

  const MessageHistoryCacheHydrated(this.page);

  @override
  List<Object?> get props => [page];
}

class MessageHistoryRemoteHydrated extends MessageState {
  final MessageHistoryPageEntity page;

  const MessageHistoryRemoteHydrated(this.page);

  @override
  List<Object?> get props => [page];
}

class MessageHistoryOlderLoading extends MessageState {}

class MessageHistoryOlderLoaded extends MessageState {
  final MessageHistoryPageEntity page;

  const MessageHistoryOlderLoaded(this.page);

  @override
  List<Object?> get props => [page];
}

class MessageHistoryOlderLoadFinished extends MessageState {}

class MessageLine extends Equatable {
  final String id;
  final String senderId;
  final String senderAvatarUrl;
  final String author;
  final String text;
  final bool fromMe;
  final DateTime? createdAt;

  const MessageLine({
    this.id = '',
    this.senderId = '',
    this.senderAvatarUrl = '',
    required this.author,
    required this.text,
    required this.fromMe,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    senderId,
    senderAvatarUrl,
    author,
    text,
    fromMe,
    createdAt,
  ];
}
