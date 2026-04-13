import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reels_entity.dart';
import '../repositories/reels_repository.dart';
import 'usecase_params.dart';

class FetchReelsItemsUseCase
    implements UseCase<List<ReelsEntity>, ReelsQueryParams> {
  final ReelsRepository _repository;

  FetchReelsItemsUseCase(this._repository);

  @override
  Future<Either<Failure, List<ReelsEntity>>> call(ReelsQueryParams params) {
    return _repository.fetchItems();
  }
}
