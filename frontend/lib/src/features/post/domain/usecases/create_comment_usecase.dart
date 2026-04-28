import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_comment_entity.dart';
import '../repositories/post_repository.dart';

class CreateCommentUseCase implements UseCase<PostCommentEntity, CreateCommentParams> {
  final PostRepository _postRepository;
  const CreateCommentUseCase(this._postRepository);

  @override
  Future<Either<Failure, PostCommentEntity>> call(CreateCommentParams params) async {
    if (params.postId.trim().isEmpty || params.content.trim().isEmpty) {
      return Left(EmptyFailure());
    }

    return _postRepository.createComment(
      params.postId,
      params.content,
      parentCommentId: params.parentCommentId,
    );
  }
}

class CreateCommentParams {
  final String postId;
  final String content;
  final String? parentCommentId;

  const CreateCommentParams({
    required this.postId,
    required this.content,
    this.parentCommentId,
  });
}
