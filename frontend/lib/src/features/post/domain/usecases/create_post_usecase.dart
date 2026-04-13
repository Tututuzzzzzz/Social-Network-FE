import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_media_entity.dart';
import '../repositories/post_repository.dart';

class CreatePostUseCase implements UseCase<void, Params> {
  final PostRepository _postRepository;
  const CreatePostUseCase(this._postRepository);

  @override
  Future<Either<Failure, void>> call(Params params) async {
    final hasContent = params.content?.trim().isNotEmpty ?? false;
    final hasMedia = params.media.isNotEmpty;

    if (!hasContent && !hasMedia) {
      return Left(EmptyFailure());
    }

    return await _postRepository.create(params);
  }
}

class Params extends Equatable {
  final String? content;
  final List<PostMediaEntity> media;

  const Params({this.content, this.media = const []});

  @override
  List<Object?> get props => [content, media];
}
