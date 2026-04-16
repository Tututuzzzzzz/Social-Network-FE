/// Domain entity for a Friend Request.
class FriendRequest {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String? avatarUrl;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    this.avatarUrl,
    required this.createdAt,
  });

  // Simple mapper from data model if needed.
  factory FriendRequest.fromMap(Map<String, dynamic> map) => FriendRequest(
    id: map['id']?.toString() ?? '',
    fromUserId: map['fromUserId']?.toString() ?? '',
    fromUserName: map['fromUserName'] ?? '',
    avatarUrl: map['avatarUrl'],
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}
