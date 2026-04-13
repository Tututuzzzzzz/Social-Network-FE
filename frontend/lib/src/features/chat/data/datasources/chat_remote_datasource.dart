import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_helper.dart';
import '../models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatModel>> fetchItems();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiHelper _apiHelper;

  const ChatRemoteDataSourceImpl(this._apiHelper);

  static const List<ChatModel> _mockItems = [
    ChatModel(
      id: 't_1',
      senderName: 'An Nguyen',
      messagePreview: 'Can we align Home Search tabs with Figma after lunch?',
      timeLabel: '2m',
      unreadCount: 2,
      isPinned: true,
      isOnline: true,
      fullConversation:
          'An: Can we align Home Search tabs with Figma after lunch?\nYou: Sure, I can push a patch right after standup.\nAn: Great, also check empty/error state spacing.',
    ),
    ChatModel(
      id: 't_2',
      senderName: 'Design Team',
      messagePreview: '4 new comments on Prototype frame mapping',
      timeLabel: '12m',
      unreadCount: 0,
      isPinned: true,
      isOnline: false,
      isGroup: true,
      fullConversation:
          'Linh: 4 new comments on Prototype frame mapping\nBinh: Please check screens under chat module.\nYou: Got it, I will update by tonight.',
    ),
    ChatModel(
      id: 't_3',
      senderName: 'Khoa Tran',
      messagePreview: 'I pushed the route alias update, please review.',
      timeLabel: '34m',
      unreadCount: 1,
      isPinned: false,
      isOnline: false,
      fullConversation:
          'Khoa: I pushed the route alias update, please review.\nYou: Looking now.\nKhoa: Thanks, especially auth redirect.',
    ),
    ChatModel(
      id: 't_4',
      senderName: 'Mina Le',
      messagePreview: 'Let us sync before tonight deploy.',
      timeLabel: '1h',
      unreadCount: 0,
      isPinned: false,
      isOnline: true,
      fullConversation:
          'Mina: Let us sync before tonight deploy.\nYou: 20:30 okay?\nMina: Perfect.',
    ),
    ChatModel(
      id: 't_5',
      senderName: 'Frontend Guild',
      messagePreview: 'Please keep reusable widgets in presentation/widgets.',
      timeLabel: '2h',
      unreadCount: 0,
      isPinned: false,
      isOnline: false,
      isGroup: true,
      fullConversation:
          'Lead: Please keep reusable widgets in presentation/widgets.\nYou: Done for Home, now extending Chat.',
    ),
  ];

  @override
  Future<List<ChatModel>> fetchItems() async {
    try {
      final result = await _apiHelper.execute(
        method: Method.get,
        url: ApiConstants.conversations,
      );
      final items = _mapConversationsToChatItems(result);
      if (items.isNotEmpty) {
        return items;
      }
    } catch (_) {
      // Ignore and fall back to mocked data when API is unavailable.
    }

    await Future<void>.delayed(const Duration(milliseconds: 320));
    return _mockItems;
  }

  List<ChatModel> _mapConversationsToChatItems(Map<String, dynamic> payload) {
    final conversationsRaw = payload['conversations'];
    if (conversationsRaw is! List) {
      return const [];
    }

    final items = <ChatModel>[];
    for (final conversationRaw in conversationsRaw) {
      if (conversationRaw is! Map) {
        continue;
      }

      final conversation = Map<String, dynamic>.from(conversationRaw);
      final id = _asText(conversation['_id']);
      if (id.isEmpty) {
        continue;
      }

      final type = _asText(conversation['type']);
      final isGroup = type == 'group';
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
        final displayName = _asText(sender['displayName']);
        if (displayName.isNotEmpty) {
          senderLabel = displayName;
        }
      }

      items.add(
        ChatModel(
          id: id,
          senderName: senderName,
          messagePreview: fallbackPreview,
          timeLabel: _formatTimeLabel(lastTimestamp),
          unreadCount: unread,
          isPinned: false,
          isOnline: false,
          isGroup: isGroup,
          fullConversation: '$senderLabel: $fallbackPreview',
        ),
      );
    }

    return items;
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

    final participantsRaw = conversation['participants'];
    if (participantsRaw is List && participantsRaw.isNotEmpty) {
      final candidateIndex = participantsRaw.length > 1 ? 1 : 0;
      final participantRaw = participantsRaw[candidateIndex];
      if (participantRaw is Map) {
        final participant = Map<String, dynamic>.from(participantRaw);
        final name = _asText(participant['displayName']);
        if (name.isNotEmpty) {
          return name;
        }
      }

      final firstRaw = participantsRaw.first;
      if (firstRaw is Map) {
        final first = Map<String, dynamic>.from(firstRaw);
        final name = _asText(first['displayName']);
        if (name.isNotEmpty) {
          return name;
        }
      }
    }

    return 'Conversation';
  }

  int _extractUnreadCount(Map<String, dynamic> conversation) {
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
