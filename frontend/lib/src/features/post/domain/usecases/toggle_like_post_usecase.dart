import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class ToggleLikePostUseCase implements UseCase<PostEntity, ToggleLikePostParams> {
  final PostRepository _postRepository;
  const ToggleLikePostUseCase(this._postRepository);

  @override
  Future<Either<Failure, PostEntity>> call(ToggleLikePostParams params) async {
    if (params.postId.trim().isEmpty) {
      return Left(EmptyFailure());
    }

    return _postRepository.toggleLike(params.postId);
  }
}

class ToggleLikePostParams {
  final String postId;

  const ToggleLikePostParams({required this.postId});
}
