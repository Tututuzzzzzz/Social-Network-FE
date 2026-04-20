import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase implements UseCase<ProfileEntity, Params> {
  final ProfileRepository _profileRepository;
  const GetProfileUseCase(this._profileRepository);

  @override
  Future<Either<Failure, ProfileEntity>> call(Params params) async {
    return await _profileRepository.getProfile(params);
  }
}

class Params extends Equatable {
  final String userId;

  const Params({required this.userId});

  @override
  List<Object?> get props => [userId];
}
