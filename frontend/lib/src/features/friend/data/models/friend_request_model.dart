// Model for friend request returned by backend
class FriendRequestModel {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String? avatarUrl;
  final DateTime createdAt;

  FriendRequestModel({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    this.avatarUrl,
    required this.createdAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id']?.toString() ?? '',
      fromUserId: json['fromUserId']?.toString() ?? '',
      fromUserName: json['fromUserName'] ?? '',
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromUserId': fromUserId,
    'fromUserName': fromUserName,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt.toIso8601String(),
  };
}
