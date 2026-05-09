import '../../domain/entities/friend.dart';

// Simple data model for a Friend returned from backend.
class FriendModel extends Friend {
  const FriendModel({required super.id, required super.name, super.avatarUrl});

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    final resolvedName =
        (json['displayName'] ?? json['username'] ?? json['name'])?.toString() ??
        '';

    return FriendModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      name: resolvedName,
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
  };
}
