import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_comment_entity.dart';
import '../repositories/post_repository.dart';

class UpdateCommentUseCase
    implements UseCase<PostCommentEntity, UpdateCommentParams> {
  final PostRepository _postRepository;
  const UpdateCommentUseCase(this._postRepository);

  @override
  Future<Either<Failure, PostCommentEntity>> call(
    UpdateCommentParams params,
  ) async {
    if (params.postId.trim().isEmpty ||
        params.commentId.trim().isEmpty ||
        params.content.trim().isEmpty) {
      return Left(EmptyFailure());
    }

    return _postRepository.updateComment(
      params.postId,
      params.commentId,
      params.content,
    );
  }
}

class UpdateCommentParams {
  final String postId;
  final String commentId;
  final String content;

  const UpdateCommentParams({
    required this.postId,
    required this.commentId,
    required this.content,
  });
}
