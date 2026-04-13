import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/reels_entity.dart';
import '../../domain/repositories/reels_repository.dart';
import '../datasources/reels_local_datasource.dart';
import '../datasources/reels_remote_datasource.dart';

class ReelsRepositoryImpl implements ReelsRepository {
  final ReelsRemoteDataSource _remoteDataSource;
  final ReelsLocalDataSource _localDataSource;

  ReelsRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, List<ReelsEntity>>> fetchItems() async {
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
