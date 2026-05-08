import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../../friend/presentation/pages/friend_picker_bottom_sheet.dart';
import '../../domain/entities/chat_entity.dart';

// ---------------------------------------------------------------------------
// Friend list helpers
// ---------------------------------------------------------------------------

Future<List<FriendPickerUser>> fetchFriendsForPicker() async {
  final apiHelper = getIt<ApiHelper>();
  final result = await apiHelper.execute(
    method: Method.get,
    url: ApiConstants.friends,
  );

  final friendsRaw = extractFriendsFromPayload(result);
  return friendsRaw.map(mapFriendItem).where((f) => f.id.isNotEmpty).toList();
}

List<Map<String, dynamic>> extractFriendsFromPayload(
  Map<String, dynamic> payload,
) {
  if (payload['friends'] is List) {
    return (payload['friends'] as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  final data = payload['data'];
  if (data is Map<String, dynamic>) {
    final friends = data['friends'];
    if (friends is List) {
      return friends
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }

  return const [];
}

FriendPickerUser mapFriendItem(Map<String, dynamic> raw) {
  final id = (raw['_id'] ?? raw['id'] ?? '').toString();
  final displayName = (raw['displayName'] ?? '').toString().trim();
  final username = (raw['username'] ?? '').toString().trim();
  final avatarUrl = (raw['avatarUrl'] ?? '').toString().trim();

  final name = displayName.isNotEmpty
      ? displayName
      : (username.isNotEmpty ? username : 'Unknown');

  return FriendPickerUser(
    id: id,
    name: name,
    username: username,
    avatarUrl: avatarUrl,
  );
}

// ---------------------------------------------------------------------------
// Group conversation response helpers
// ---------------------------------------------------------------------------

String extractGroupName(
  Map<String, dynamic> conversation, {
  required String fallback,
}) {
  final groupRaw = conversation['group'];
  if (groupRaw is Map) {
    final group = Map<String, dynamic>.from(groupRaw);
    final name = (group['name'] ?? '').toString().trim();
    if (name.isNotEmpty) {
      return name;
    }
  }

  final name = (conversation['name'] ?? '').toString().trim();
  return name.isNotEmpty ? name : (fallback.isNotEmpty ? fallback : 'Group');
}

String extractGroupAvatar(Map<String, dynamic> conversation) {
  final groupRaw = conversation['group'];
  if (groupRaw is Map) {
    final group = Map<String, dynamic>.from(groupRaw);
    final avatarUrl = (group['avatarUrl'] ?? '').toString().trim();
    if (avatarUrl.isNotEmpty) {
      return avatarUrl;
    }
    final avatar = (group['avatar'] ?? '').toString().trim();
    if (avatar.isNotEmpty) {
      return avatar;
    }
  }

  final direct = (conversation['groupAvatarUrl'] ?? '').toString().trim();
  return direct;
}

int extractGroupMemberCount(
  Map<String, dynamic> conversation,
  List<String> memberIds,
) {
  final participantsRaw = conversation['participants'];
  if (participantsRaw is List) {
    return participantsRaw.length;
  }

  final groupRaw = conversation['group'];
  if (groupRaw is Map) {
    final group = Map<String, dynamic>.from(groupRaw);
    final countRaw = group['membersCount'] ?? group['memberCount'];
    if (countRaw is num) {
      return countRaw.toInt();
    }
  }

  return memberIds.length + 1;
}

// ---------------------------------------------------------------------------
// Create direct conversation – API fallback
// ---------------------------------------------------------------------------

Future<ChatEntity?> createDirectConversationFallback(
  ApiHelper apiHelper,
  String friendId,
  String friendName,
  String friendAvatarUrl,
) async {
  final result = await apiHelper.execute(
    method: Method.post,
    url: ApiConstants.conversations,
    data: {'type': 'direct', 'recipientId': friendId},
  );

  final raw = result['conversation'];
  if (raw is! Map) {
    return null;
  }

  final map = Map<String, dynamic>.from(raw);
  final id = (map['_id'] ?? map['id'] ?? '').toString();
  if (id.isEmpty) {
    return null;
  }

  return ChatEntity(
    id: id,
    recipientId: friendId,
    senderName: friendName,
    messagePreview: 'Start chatting...',
    timeLabel: 'now',
    isGroup: false,
    avatarUrl: friendAvatarUrl,
    fullConversation: '$friendName: Start chatting...',
  );
}

// ---------------------------------------------------------------------------
// Create group conversation
// ---------------------------------------------------------------------------

Future<ChatEntity?> createGroupConversation(
  ApiHelper apiHelper, {
  required String name,
  required List<String> memberIds,
}) async {
  final result = await apiHelper.execute(
    method: Method.post,
    url: ApiConstants.conversations,
    data: {'type': 'group', 'name': name.trim(), 'memberIds': memberIds},
  );

  final raw = result['conversation'];
  if (raw is! Map) {
    return null;
  }

  final map = Map<String, dynamic>.from(raw);
  final id = (map['_id'] ?? map['id'] ?? '').toString();
  if (id.isEmpty) {
    return null;
  }

  final groupName = extractGroupName(map, fallback: name.trim());
  final avatarUrl = extractGroupAvatar(map);
  final participantCount = extractGroupMemberCount(map, memberIds);

  return ChatEntity(
    id: id,
    senderName: groupName,
    messagePreview: 'Group created',
    timeLabel: 'now',
    isGroup: true,
    participantCount: participantCount,
    avatarUrl: avatarUrl,
    fullConversation: '$groupName: Group created',
  );
}
