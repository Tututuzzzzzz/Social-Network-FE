import '../entities/admin_session.dart';

abstract class AdminAuthRepository {
  Future<AdminSession> login({
    required String username,
    required String password,
  });

  Future<AdminSession?> restoreSession();

  Future<void> logout();
}
