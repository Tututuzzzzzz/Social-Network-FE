import 'package:equatable/equatable.dart';

class AdminUser extends Equatable {
  final String id;
  final String username;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final int postsCount;
  final int? friendsCount;
  final String? bio;
  final String? phone;
  final DateTime? lastActivityAt;
  final DateTime? createdAt;

  const AdminUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.email,
    this.avatarUrl,
    required this.postsCount,
    this.friendsCount,
    this.bio,
    this.phone,
    this.lastActivityAt,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    displayName,
    email,
    avatarUrl,
    postsCount,
    friendsCount,
    bio,
    phone,
    lastActivityAt,
    createdAt,
  ];
}
