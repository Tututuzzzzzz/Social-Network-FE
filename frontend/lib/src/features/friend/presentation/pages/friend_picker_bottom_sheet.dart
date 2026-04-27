import 'package:flutter/material.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_helper.dart';

class FriendPickerUser {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;

  const FriendPickerUser({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
  });
}

Future<FriendPickerUser?> showFriendPickerBottomSheet(
  BuildContext context,
) async {
  return showModalBottomSheet<FriendPickerUser>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5D7DD),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ban be',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111113),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: MediaQuery.of(sheetContext).size.height * 0.55,
                child: FutureBuilder<List<FriendPickerUser>>(
                  future: _fetchFriendsForPicker(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Khong tai duoc danh sach ban be'),
                      );
                    }

                    final friends = snapshot.data ?? const <FriendPickerUser>[];
                    if (friends.isEmpty) {
                      return const Center(
                        child: Text('Ban chua co ban be nao'),
                      );
                    }

                    return ListView.separated(
                      itemCount: friends.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE8EBF4),
                            backgroundImage: friend.avatarUrl.isNotEmpty
                                ? NetworkImage(friend.avatarUrl)
                                : null,
                            child: friend.avatarUrl.isNotEmpty
                                ? null
                                : Text(
                                    friend.name.isNotEmpty
                                        ? friend.name[0].toUpperCase()
                                        : '?',
                                  ),
                          ),
                          title: Text(friend.name),
                          subtitle: friend.username.isEmpty
                              ? null
                              : Text('@${friend.username}'),
                          trailing: const Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                          ),
                          onTap: () => Navigator.of(sheetContext).pop(friend),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<List<FriendPickerUser>> _fetchFriendsForPicker() async {
  final apiHelper = getIt<ApiHelper>();
  final result = await apiHelper.execute(
    method: Method.get,
    url: ApiConstants.friends,
  );

  final friendsRaw = _extractFriendsFromPayload(result);
  return friendsRaw.map(_mapFriendItem).where((f) => f.id.isNotEmpty).toList();
}

List<Map<String, dynamic>> _extractFriendsFromPayload(
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

FriendPickerUser _mapFriendItem(Map<String, dynamic> raw) {
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
