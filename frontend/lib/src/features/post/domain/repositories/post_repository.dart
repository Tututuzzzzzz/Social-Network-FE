import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post_entity.dart';
import '../usecases/usecase_params.dart';

abstract class PostRepository {
  Future<Either<Failure, List<PostEntity>>> getAll();
  Future<Either<Failure, void>> create(CreatePostParams params);
  Future<Either<Failure, void>> update(UpdatePostParams params);
  Future<Either<Failure, void>> delete(DeletePostParams params);
}
