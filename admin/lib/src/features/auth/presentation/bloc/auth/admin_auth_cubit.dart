import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_admin_usecase.dart';
import '../../../domain/usecases/logout_admin_usecase.dart';
import '../../../domain/usecases/restore_admin_session_usecase.dart';
import 'admin_auth_state.dart';

class AdminAuthCubit extends Cubit<AdminAuthState> {
  final LoginAdminUseCase _loginAdmin;
  final LogoutAdminUseCase _logoutAdmin;
  final RestoreAdminSessionUseCase _restoreSession;

  AdminAuthCubit(this._loginAdmin, this._logoutAdmin, this._restoreSession)
    : super(const AdminAuthState.checking());

  Future<void> bootstrap() async {
    final session = await _restoreSession();
    if (session == null) {
      emit(const AdminAuthState.unauthenticated());
      return;
    }

    emit(
      AdminAuthState(status: AdminAuthStatus.authenticated, session: session),
    );
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(
      state.copyWith(status: AdminAuthStatus.submitting, clearMessage: true),
    );

    try {
      final session = await _loginAdmin(username: username, password: password);
      emit(
        AdminAuthState(status: AdminAuthStatus.authenticated, session: session),
      );
    } catch (error) {
      emit(
        AdminAuthState(
          status: AdminAuthStatus.unauthenticated,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> logout() async {
    await _logoutAdmin();
    emit(const AdminAuthState.unauthenticated());
  }
}
