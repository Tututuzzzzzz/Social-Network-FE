import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/search_entity.dart';

abstract class SearchRepository {
  Future<Either<Failure, SearchResponseEntity>> searchUsers({
    required String name,
    required int page,
    required int limit,
  });

  Future<Either<Failure, List<SearchHistoryEntry>>> getSearchHistory();
  Future<Either<Failure, void>> saveSearchQuery(SearchHistoryEntry entry);
  Future<Either<Failure, void>> clearSearchHistory();
}
