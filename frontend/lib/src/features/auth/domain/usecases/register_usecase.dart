import 'package:equatable/equatable.dart';
import 'package:frontend/src/core/extensions/string_validator_extension.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class AuthRegisterUseCase implements UseCase<void, Params> {
  final AuthRepository _authRepository;
  const AuthRegisterUseCase(this._authRepository);

  @override
  Future<Either<Failure, void>> call(Params params) async {
    if (!params.email.isValidEmail) {
      return Left(InvalidEmailFailure());
    }

    if (!params.password.isValidPassword ||
        !params.confirmPassword.isValidPassword) {
      return Left(InvalidPasswordFailure());
    }

    if (params.password != params.confirmPassword) {
      return Left(PasswordNotMatchFailure());
    }

    return await _authRepository.register(params);
  }
}

class Params extends Equatable {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  const Params({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

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
