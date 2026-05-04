import 'package:equatable/equatable.dart';

class AdminSession extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final String userId;
  final String username;
  final bool isEmailVerified;

  const AdminSession({
    required this.accessToken,
    this.refreshToken,
    required this.userId,
    required this.username,
    required this.isEmailVerified,
  });

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    userId,
    username,
    isEmailVerified,
  ];
}
