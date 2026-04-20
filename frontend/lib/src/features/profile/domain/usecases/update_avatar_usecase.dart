import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UpdateAvatarUseCase implements UseCase<void, Params> {
  final ProfileRepository _profileRepository;
  const UpdateAvatarUseCase(this._profileRepository);

  @override
  Future<Either<Failure, void>> call(Params params) async {
    return await _profileRepository.updateAvatar(params);
  }
}

class Params extends Equatable {
  final List<int> avatarBytes;
  final String fileName;

  const Params({required this.avatarBytes, required this.fileName});

  @override
  List<Object?> get props => [avatarBytes, fileName];
}
