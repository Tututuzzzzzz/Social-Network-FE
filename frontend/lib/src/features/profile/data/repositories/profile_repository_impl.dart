import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final ProfileLocalDataSource _localDataSource;

  ProfileRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, List<ProfileEntity>>> fetchItems() async {
    try {
      final remoteItems = await _remoteDataSource.fetchItems();
      if (remoteItems.isNotEmpty) {
        return right(remoteItems);
      }

      final localItems = await _localDataSource.fetchItems();
      return right(localItems);
    } catch (_) {
      return left(ServerFailure());
    }
  }
}
