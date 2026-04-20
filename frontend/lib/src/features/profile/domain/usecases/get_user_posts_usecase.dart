import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../post/domain/entities/post_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserPostsUseCase implements UseCase<List<PostEntity>, Params> {
  final ProfileRepository _profileRepository;
  const GetUserPostsUseCase(this._profileRepository);

  @override
  Future<Either<Failure, List<PostEntity>>> call(Params params) async {
    return await _profileRepository.getUserPosts(params);
  }
}

class Params extends Equatable {
  final String userId;
  final int page;
  final int limit;

  const Params({required this.userId, this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [userId, page, limit];
}
