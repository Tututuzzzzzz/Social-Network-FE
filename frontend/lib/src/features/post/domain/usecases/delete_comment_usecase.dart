import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/post_repository.dart';

class DeleteCommentUseCase implements UseCase<void, DeleteCommentParams> {
  final PostRepository _postRepository;
  const DeleteCommentUseCase(this._postRepository);

  @override
  Future<Either<Failure, void>> call(DeleteCommentParams params) async {
    if (params.postId.trim().isEmpty || params.commentId.trim().isEmpty) {
      return Left(EmptyFailure());
    }

    return _postRepository.deleteComment(params.postId, params.commentId);
  }
}

class DeleteCommentParams {
  final String postId;
  final String commentId;

  const DeleteCommentParams({
    required this.postId,
    required this.commentId,
  });
}
