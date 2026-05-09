import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/injector/injector_conf.dart';
import '../../../../../core/realtime/realtime_socket_service.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/utils/failure_converter.dart';
import '../../../../../core/utils/logger.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/check_signin_status_usecase.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../../domain/usecases/register_usecase.dart';
import '../../../domain/usecases/forgot_password_usecase.dart';
import '../../../domain/usecases/usecase_params.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthLoginUseCase _loginUseCase;
  final AuthRegisterUseCase _registerUseCase;
  final AuthLogoutUseCase _logoutUseCase;
  final AuthCheckSignInStatusUseCase _checkSignInStatusUseCase;
  final AuthForgotPasswordUseCase _forgotPasswordUseCase;
  AuthBloc(
    this._loginUseCase,
    this._logoutUseCase,
    this._registerUseCase,
    this._checkSignInStatusUseCase,
    this._forgotPasswordUseCase,
  ) : super(AuthInitialState()) {
    on<AuthLoginEvent>(_login);
    on<AuthLogoutEvent>(_logout);
    on<AuthRegisterEvent>(_register);
    on<AuthCheckSignInStatusEvent>(_checkSignInStatus);
    on<AuthForgotPasswordEvent>(_forgotPassword);
  }

  Future _login(AuthLoginEvent event, Emitter emit) async {
    emit(AuthLoginLoadingState());

    final result = await _loginUseCase.call(
      LoginParams(
        username: event.username,
        password: event.password,
        rememberMe: event.rememberMe,
      ),
    );

    result.fold(
      (l) => emit(AuthLoginFailureState(mapFailureToMessage(l))),
      (r) => emit(AuthLoginSuccessState(r)),
    );
  }

  Future _logout(AuthLogoutEvent event, Emitter emit) async {
    emit(AuthLogoutLoadingState());

    // Disconnect socket trước khi xóa token
    getIt<RealtimeSocketService>().disconnect();

    final result = await _logoutUseCase.call(NoParams());

    result.fold(
      (l) => emit(AuthLogoutFailureState(mapFailureToMessage(l))),
      (r) => emit(const AuthLogoutSuccessState("Logout Success")),
    );
  }

  Future _register(AuthRegisterEvent event, Emitter emit) async {
    emit(AuthRegisterLoadingState());

    final result = await _registerUseCase.call(
      RegisterParams(
        firstName: event.firstName,
        lastName: event.lastName,
        username: event.username,
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
      ),
    );

    result.fold(
      (l) => emit(AuthRegisterFailureState(mapFailureToMessage(l))),
      (r) => emit(const AuthRegisterSuccessState("Register Success")),
    );
  }

  Future _checkSignInStatus(
    AuthCheckSignInStatusEvent event,
    Emitter emit,
  ) async {
    emit(AuthCheckSignInStatusLoadingState());

    final result = await _checkSignInStatusUseCase.call(NoParams());

    result.fold(
      (l) => emit(AuthCheckSignInStatusFailureState(mapFailureToMessage(l))),
      (r) => emit(AuthCheckSignInStatusSuccessState(r)),
    );
  }

  Future _forgotPassword(
    AuthForgotPasswordEvent event,
    Emitter emit,
  ) async {
    emit(AuthForgotPasswordLoadingState());

    final result = await _forgotPasswordUseCase.call(event.email);

    result.fold(
      (l) => emit(AuthForgotPasswordFailureState(mapFailureToMessage(l))),
      (r) => emit(const AuthForgotPasswordSuccessState(
        "Mật khẩu mới đã được gửi đến email của bạn!",
      )),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE AuthBloc =====");
    return super.close();
  }
}
