import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/search_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_local_datasource.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;
  final SearchLocalDataSource localDataSource;

  SearchRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, SearchResponseEntity>> searchUsers({
    required String name,
    required int page,
    required int limit,
  }) async {
    try {
      final result = await remoteDataSource.searchUsers(
        name: name,
        page: page,
        limit: limit,
      );
      return right(result.toEntity());
    } on ServerException {
      return left(ServerFailure());
    } catch (_) {
      return left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SearchHistoryEntry>>> getSearchHistory() async {
    try {
      final result = await localDataSource.getSearchHistory();
      return right(result);
    } on CacheException {
      return left(CacheFailure());
    } catch (_) {
      return left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveSearchQuery(SearchHistoryEntry entry) async {
    try {
      await localDataSource.saveSearchQuery(entry);
      return right(null);
    } on CacheException {
      return left(CacheFailure());
    } catch (_) {
      return left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> clearSearchHistory() async {
    try {
      await localDataSource.clearSearchHistory();
      return right(null);
    } on CacheException {
      return left(CacheFailure());
    } catch (_) {
      return left(CacheFailure());
    }
  }
}
