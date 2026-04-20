import 'package:flutter/material.dart';

import '../../domain/entities/friend_request.dart';

class FriendRequestTile extends StatelessWidget {
  final FriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const FriendRequestTile({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: request.avatarUrl != null
          ? CircleAvatar(backgroundImage: NetworkImage(request.avatarUrl!))
          : const CircleAvatar(child: Icon(Icons.person)),
      title: Text(request.fromUserName),
      subtitle: Text('From: ${request.fromUserId}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onAccept,
            icon: const Icon(Icons.check, color: Colors.green),
          ),
          IconButton(
            onPressed: onReject,
            icon: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
