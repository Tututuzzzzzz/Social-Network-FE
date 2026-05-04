import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post_entity.dart';
import '../entities/post_comment_entity.dart';
import '../entities/post_comments_entity.dart';
import '../entities/post_media_entity.dart';
import '../entities/post_media_upload_file.dart';
import '../usecases/usecase_params.dart';

abstract class PostRepository {
  Future<Either<Failure, List<PostEntity>>> getAll();
  Future<Either<Failure, void>> create(CreatePostParams params);
  Future<Either<Failure, void>> update(UpdatePostParams params);
  Future<Either<Failure, void>> delete(DeletePostParams params);
  Future<Either<Failure, List<PostMediaEntity>>> uploadMedia(
    List<PostMediaUploadFile> files,
  );
  Future<Either<Failure, PostEntity>> toggleLike(String postId);
  Future<Either<Failure, PostCommentEntity>> createComment(
    String postId,
    String content, {
    String? parentCommentId,
  });
  Future<Either<Failure, PostCommentsEntity>> getComments(String postId);
}
