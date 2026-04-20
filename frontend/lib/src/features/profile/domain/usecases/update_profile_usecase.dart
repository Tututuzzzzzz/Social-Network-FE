import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<void, Params> {
  final ProfileRepository _profileRepository;
  const UpdateProfileUseCase(this._profileRepository);

  @override
  Future<Either<Failure, void>> call(Params params) async {
    return await _profileRepository.updateProfile(params);
  }
}

class Params extends Equatable {
  final String? displayName;
  final String? bio;
  final String? phone;

  const Params({this.displayName, this.bio, this.phone});

  @override
  List<Object?> get props => [displayName, bio, phone];
}
