import 'package:flutter/material.dart';

class HomeUserResult {
  final String id;
  final String name;
  final String handle;
  final int mutualFriends;
  final bool isOnline;

  const HomeUserResult({
    required this.id,
    required this.name,
    required this.handle,
    required this.mutualFriends,
    required this.isOnline,
  });
}

class HomeUserResultTile extends StatelessWidget {
  final HomeUserResult item;
  final VoidCallback? onTap;
  final VoidCallback? onTapFollow;

  const HomeUserResultTile({
    super.key,
    required this.item,
    this.onTap,
    this.onTapFollow,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Stack(
        children: [
          CircleAvatar(radius: 22, child: Text(item.name.substring(0, 1))),
          if (item.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF26A65B),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.6),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        item.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('@${item.handle} · ${item.mutualFriends} mutual'),
      trailing: FilledButton.tonal(
        onPressed: onTapFollow,
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: const Text('Follow'),
      ),
    );
  }
}
