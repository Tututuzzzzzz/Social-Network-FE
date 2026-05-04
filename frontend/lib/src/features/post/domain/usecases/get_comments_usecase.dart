import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_comments_entity.dart';
import '../repositories/post_repository.dart';

class GetCommentsUseCase implements UseCase<PostCommentsEntity, GetCommentsParams> {
  final PostRepository _postRepository;
  const GetCommentsUseCase(this._postRepository);

  @override
  Future<Either<Failure, PostCommentsEntity>> call(GetCommentsParams params) async {
    if (params.postId.trim().isEmpty) {
      return Left(EmptyFailure());
    }

    return _postRepository.getComments(params.postId);
  }
}

class GetCommentsParams {
  final String postId;

  const GetCommentsParams({required this.postId});
}
