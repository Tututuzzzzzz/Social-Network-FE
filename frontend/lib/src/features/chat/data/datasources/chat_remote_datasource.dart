import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatModel>> fetchItems();
  Future<ChatModel> createDirectConversation({required String recipientId});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiHelper _apiHelper;

  const ChatRemoteDataSourceImpl(this._apiHelper);

  @override
  Future<List<ChatModel>> fetchItems() async {
    try {
      final result = await _apiHelper.execute(
        method: Method.get,
        url: ApiConstants.conversations,
      );
      return _mapConversationsToChatItems(result);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<ChatModel> createDirectConversation({
    required String recipientId,
  }) async {
    try {
      final result = await _apiHelper.execute(
        method: Method.post,
        url: ApiConstants.conversations,
        data: {'type': 'direct', 'recipientId': recipientId},
      );

      final conversationRaw = result['conversation'];
      if (conversationRaw is! Map) {
        throw ServerException();
      }

      final conversation = Map<String, dynamic>.from(conversationRaw);
      return _mapConversationToChatItem(conversation);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  List<ChatModel> _mapConversationsToChatItems(Map<String, dynamic> payload) {
    final conversationsRaw = _extractConversations(payload);
    if (conversationsRaw is! List) {
      return const [];
    }

    final items = <ChatModel>[];
    for (final conversationRaw in conversationsRaw) {
      if (conversationRaw is! Map) {
        continue;
      }

      final conversation = Map<String, dynamic>.from(conversationRaw);
      final mapped = _mapConversationToChatItem(conversation);
      if (mapped.id.isNotEmpty) {
        items.add(mapped);
      }
    }

    return items;
  }

  ChatModel _mapConversationToChatItem(Map<String, dynamic> conversation) {
    final id = _asText(conversation['_id']).isNotEmpty
        ? _asText(conversation['_id'])
        : _asText(conversation['id']);

    final type = _asText(conversation['type']);
    final isGroup = type == 'group';
    final recipientId = _extractRecipientId(conversation, isGroup);
    final senderName = _extractSenderName(conversation, isGroup);
    final lastMessageRaw = conversation['lastMessage'];
    Map<String, dynamic>? lastMessage;
    if (lastMessageRaw is Map) {
      lastMessage = Map<String, dynamic>.from(lastMessageRaw);
    }

    final preview = _asText(lastMessage?['content']);
    final fallbackPreview = preview.isNotEmpty ? preview : 'No messages yet';
    final lastTimestamp = _asText(lastMessage?['createdAt']).isNotEmpty
        ? _asText(lastMessage?['createdAt'])
        : _asText(conversation['lastMessageAt']);

    final unread = _extractUnreadCount(conversation);

    final senderRaw = lastMessage?['senderId'];
    String senderLabel = senderName;
    if (senderRaw is Map) {
      final sender = Map<String, dynamic>.from(senderRaw);
      final displayName = _asText(sender['displayName']).isNotEmpty
          ? _asText(sender['displayName'])
          : _asText(sender['username']);
      if (displayName.isNotEmpty) {
        senderLabel = displayName;
      }
    }

    return ChatModel(
      id: id,
      recipientId: recipientId,
      senderName: senderName,
      messagePreview: fallbackPreview,
      timeLabel: _formatTimeLabel(lastTimestamp),
      unreadCount: unread,
      isPinned: false,
      isOnline: false,
      isGroup: isGroup,
      fullConversation: '$senderLabel: $fallbackPreview',
    );
  }

  dynamic _extractConversations(Map<String, dynamic> payload) {
    if (payload['conversations'] is List) {
      return payload['conversations'];
    }

    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      if (data['conversations'] is List) {
        return data['conversations'];
      }
      if (data['items'] is List) {
        return data['items'];
      }
      if (data['docs'] is List) {
        return data['docs'];
      }
    }

    if (payload['items'] is List) {
      return payload['items'];
    }

    if (payload['docs'] is List) {
      return payload['docs'];
    }

    return const [];
  }

  String _extractSenderName(Map<String, dynamic> conversation, bool isGroup) {
    if (isGroup) {
      final groupRaw = conversation['group'];
      if (groupRaw is Map) {
        final group = Map<String, dynamic>.from(groupRaw);
        final groupName = _asText(group['name']);
        if (groupName.isNotEmpty) {
          return groupName;
        }
      }
      return 'Group chat';
    }

    final recipientDisplayName = _asText(conversation['recipientDisplayName']);
    if (recipientDisplayName.isNotEmpty) {
      return recipientDisplayName;
    }

    final participantsRaw = conversation['participants'];
    if (participantsRaw is List && participantsRaw.isNotEmpty) {
      final candidateIndex = participantsRaw.length > 1 ? 1 : 0;
      final participantRaw = participantsRaw[candidateIndex];
      if (participantRaw is Map) {
        final participant = Map<String, dynamic>.from(participantRaw);
        final name = _asDisplayName(participant);
        if (name.isNotEmpty) {
          return name;
        }
      }

      final firstRaw = participantsRaw.first;
      if (firstRaw is Map) {
        final first = Map<String, dynamic>.from(firstRaw);
        final name = _asDisplayName(first);
        if (name.isNotEmpty) {
          return name;
        }
      }
    }

    return 'Conversation';
  }

  String _extractRecipientId(Map<String, dynamic> conversation, bool isGroup) {
    if (isGroup) {
      return '';
    }

    final directRecipientId = _asText(conversation['recipientId']);
    if (directRecipientId.isNotEmpty) {
      return directRecipientId;
    }

    final participantsRaw = conversation['participants'];
    if (participantsRaw is! List || participantsRaw.isEmpty) {
      return '';
    }

    final candidateIndex = participantsRaw.length > 1 ? 1 : 0;
    final candidateRaw = participantsRaw[candidateIndex];
    if (candidateRaw is Map) {
      final candidate = Map<String, dynamic>.from(candidateRaw);
      final id = _extractUserId(candidate);
      if (id.isNotEmpty) {
        return id;
      }
    }

    final firstRaw = participantsRaw.first;
    if (firstRaw is Map) {
      final first = Map<String, dynamic>.from(firstRaw);
      return _extractUserId(first);
    }

    return '';
  }

  String _extractUserId(Map<String, dynamic> participant) {
    final direct = _asText(participant['_id']);
    if (direct.isNotEmpty) {
      return direct;
    }

    final userIdRaw = participant['userId'];
    if (userIdRaw is String) {
      return userIdRaw;
    }

    if (userIdRaw is Map) {
      final nested = Map<String, dynamic>.from(userIdRaw);
      final nestedId = _asText(nested['_id']);
      if (nestedId.isNotEmpty) {
        return nestedId;
      }
      return _asText(nested['id']);
    }

    return _asText(participant['id']);
  }

  int _extractUnreadCount(Map<String, dynamic> conversation) {
    final directUnread = conversation['unreadCount'];
    if (directUnread is num) {
      return directUnread.toInt();
    }

    final unreadRaw = conversation['unreadCounts'];
    if (unreadRaw is Map) {
      final unreadMap = Map<String, dynamic>.from(unreadRaw);
      if (unreadMap.isEmpty) {
        return 0;
      }

      final values =
          unreadMap.values.map((item) => (item as num?)?.toInt() ?? 0).toList()
            ..sort();

      return values.isEmpty ? 0 : values.last;
    }

    return 0;
  }

  String _asDisplayName(Map<String, dynamic> participant) {
    final displayName = _asText(participant['displayName']);
    if (displayName.isNotEmpty) {
      return displayName;
    }

    final username = _asText(participant['username']);
    if (username.isNotEmpty) {
      return username;
    }

    final nestedUser = participant['userId'];
    if (nestedUser is Map) {
      final nested = Map<String, dynamic>.from(nestedUser);
      final nestedDisplayName = _asText(nested['displayName']);
      if (nestedDisplayName.isNotEmpty) {
        return nestedDisplayName;
      }
      final nestedUsername = _asText(nested['username']);
      if (nestedUsername.isNotEmpty) {
        return nestedUsername;
      }
    }

    return '';
  }

  String _formatTimeLabel(String isoValue) {
    if (isoValue.isEmpty) {
      return 'now';
    }

    final parsed = DateTime.tryParse(isoValue);
    if (parsed == null) {
      return 'now';
    }

    final now = DateTime.now();
    final diff = now.difference(parsed.toLocal());

    if (diff.inMinutes < 1) {
      return 'now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d';
    }

    return '${parsed.month}/${parsed.day}';
  }

  String _asText(Object? value) {
    return value?.toString().trim() ?? '';
  }
}
