import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetPostByIdUseCase implements UseCase<PostEntity, GetPostByIdParams> {
  final PostRepository _postRepository;

  const GetPostByIdUseCase(this._postRepository);

  @override
  Future<Either<Failure, PostEntity>> call(GetPostByIdParams params) async {
    if (params.postId.trim().isEmpty) {
      return Left(EmptyFailure());
    }

    return _postRepository.getById(params.postId);
  }
}

class GetPostByIdParams {
  final String postId;

  const GetPostByIdParams({required this.postId});
}
