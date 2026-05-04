import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_media_entity.dart';
import '../entities/post_media_upload_file.dart';
import '../repositories/post_repository.dart';

class UploadPostMediaUseCase
    implements UseCase<List<PostMediaEntity>, Params> {
  final PostRepository _postRepository;
  const UploadPostMediaUseCase(this._postRepository);

  @override
  Future<Either<Failure, List<PostMediaEntity>>> call(Params params) async {
    if (params.files.isEmpty) {
      return const Right(<PostMediaEntity>[]);
    }

    return await _postRepository.uploadMedia(params.files);
  }
}

class Params extends Equatable {
  final List<PostMediaUploadFile> files;

  const Params({this.files = const []});

  @override
  List<Object?> get props => [files];
}
