import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';
import 'usecase_params.dart';

class FetchProfileItemsUseCase
    implements UseCase<List<ProfileEntity>, ProfileQueryParams> {
  final ProfileRepository _repository;

  FetchProfileItemsUseCase(this._repository);

  @override
  Future<Either<Failure, List<ProfileEntity>>> call(ProfileQueryParams params) {
    return _repository.fetchItems();
  }
}
