import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/post_repository.dart';

class DeletePostUseCase implements UseCase<void, Params> {
  final PostRepository _postRepository;
  const DeletePostUseCase(this._postRepository);

  @override
  Future<Either<Failure, void>> call(Params params) async {
    if (params.postId.trim().isEmpty) {
      return Left(EmptyFailure());
    }

    return await _postRepository.delete(params);
  }
}

class Params extends Equatable {
  final String postId;
  const Params({required this.postId});

  @override
  List<Object?> get props => [postId];
}
