import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;
  final HomeLocalDataSource _localDataSource;

  HomeRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, List<HomeEntity>>> fetchItems() async {
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
