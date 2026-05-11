import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/search_entity.dart';
import '../repositories/search_repository.dart';

class SearchUserUseCase {
  final SearchRepository repository;

  SearchUserUseCase(this.repository);

  Future<Either<Failure, SearchResponseEntity>> call({
    required String name,
    int page = 1,
    int limit = 20,
  }) async {
    final normalized = name.trim();
    return repository.searchUsers(name: normalized, page: page, limit: limit);
  }
}

class GetSearchHistoryUseCase {
  final SearchRepository repository;

  GetSearchHistoryUseCase(this.repository);

  Future<Either<Failure, List<SearchHistoryEntry>>> call() {
    return repository.getSearchHistory();
  }
}

class SaveSearchQueryUseCase {
  final SearchRepository repository;

  SaveSearchQueryUseCase(this.repository);

  Future<Either<Failure, void>> call(SearchHistoryEntry entry) {
    return repository.saveSearchQuery(entry);
  }
}

class ClearSearchHistoryUseCase {
  final SearchRepository repository;

  ClearSearchHistoryUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.clearSearchHistory();
  }
}
