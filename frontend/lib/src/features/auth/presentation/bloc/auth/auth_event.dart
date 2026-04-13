part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginEvent(this.username, this.password);

  @override
  List<Object?> get props => [username, password];
}

class AuthRegisterEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;
  final String confirmPassword;

  const AuthRegisterEvent(
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.password,
    this.confirmPassword,
  );

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    username,
    email,
    password,
    confirmPassword,
  ];
}

class AuthLogoutEvent extends AuthEvent {}

class AuthCheckSignInStatusEvent extends AuthEvent {}
