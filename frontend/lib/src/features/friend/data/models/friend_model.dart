// Simple data model for a Friend returned from backend.
class FriendModel {
  final String id;
  final String name;
  final String? avatarUrl;

  FriendModel({required this.id, required this.name, this.avatarUrl});

  factory FriendModel.fromJson(Map<String, dynamic> json) => FriendModel(
    id: json['id']?.toString() ?? '',
    name: json['name'] ?? '',
    avatarUrl: json['avatarUrl'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
  };
}
