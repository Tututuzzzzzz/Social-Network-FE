import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';
import 'usecase_params.dart';

class FetchHomeItemsUseCase
    implements UseCase<List<HomeEntity>, HomeQueryParams> {
  final HomeRepository _repository;

  FetchHomeItemsUseCase(this._repository);

  @override
  Future<Either<Failure, List<HomeEntity>>> call(HomeQueryParams params) {
    return _repository.fetchItems();
  }
}
