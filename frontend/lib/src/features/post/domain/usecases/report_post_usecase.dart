import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/post_repository.dart';

class ReportPostUseCase implements UseCase<void, ReportPostParams> {
  final PostRepository _postRepository;
  const ReportPostUseCase(this._postRepository);

  @override
  Future<Either<Failure, void>> call(ReportPostParams params) async {
    if (params.postId.trim().isEmpty || params.reason.trim().isEmpty) {
      return Left(EmptyFailure());
    }

    return _postRepository.reportPost(
      postId: params.postId,
      reason: params.reason,
      description: params.description,
    );
  }
}

class ReportPostParams extends Equatable {
  final String postId;
  final String reason;
  final String description;

  const ReportPostParams({
    required this.postId,
    required this.reason,
    required this.description,
  });

  @override
  List<Object?> get props => [postId, reason, description];
}
