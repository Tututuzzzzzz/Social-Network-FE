import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class AuthForgotPasswordUseCase implements UseCase<void, String> {
  final AuthRepository _repository;
  const AuthForgotPasswordUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await _repository.forgotPassword(params);
  }
}
