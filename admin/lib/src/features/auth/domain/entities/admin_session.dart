import 'package:equatable/equatable.dart';

class AdminSession extends Equatable {
  final String accessToken;
  final String userId;
  final String username;
  final bool isEmailVerified;

  const AdminSession({
    required this.accessToken,
    required this.userId,
    required this.username,
    required this.isEmailVerified,
  });

  @override
  List<Object?> get props => [accessToken, userId, username, isEmailVerified];
}
