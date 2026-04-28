// Simple data model for a Friend returned from backend.
class FriendModel {
  final String id;
  final String name;
  final String? avatarUrl;

  FriendModel({required this.id, required this.name, this.avatarUrl});

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    final resolvedName = (json['displayName'] ?? json['username'] ?? json['name'])
        ?.toString() ??
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
