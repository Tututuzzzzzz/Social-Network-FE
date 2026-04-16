import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_media_entity.dart';
import '../repositories/post_repository.dart';

class UpdatePostUseCase implements UseCase<void, Params> {
  final PostRepository _postRepository;
  const UpdatePostUseCase(this._postRepository);

  @override
  Future<Either<Failure, void>> call(Params params) async {
    if (params.postId.trim().isEmpty) {
      return Left(EmptyFailure());
    }

    if (!params.hasContentField && !params.hasMediaField) {
      return Left(EmptyFailure());
    }

    return await _postRepository.update(params);
  }
}

class Params extends Equatable {
  final String postId;
  final String? content;
  final List<PostMediaEntity>? media;
  final bool hasContentField;
  final bool hasMediaField;

  const Params({
    required this.postId,
    this.content,
    this.media,
    this.hasContentField = false,
    this.hasMediaField = false,
  });

  @override
  List<Object?> get props => [
    postId,
    content,
    media,
    hasContentField,
    hasMediaField,
  ];
}
