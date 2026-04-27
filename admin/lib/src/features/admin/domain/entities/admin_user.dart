import 'package:equatable/equatable.dart';

class AdminUser extends Equatable {
  final String id;
  final String username;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final int postsCount;
  final DateTime? lastActivityAt;

  const AdminUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.email,
    this.avatarUrl,
    required this.postsCount,
    this.lastActivityAt,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    displayName,
    email,
    avatarUrl,
    postsCount,
    lastActivityAt,
  ];
}
