part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

final class SearchInitialState extends SearchState {
  const SearchInitialState();
}

final class SearchHistoryLoadingState extends SearchState {
  const SearchHistoryLoadingState();
}

final class SearchHistoryLoadedState extends SearchState {
  final List<SearchHistoryEntry> history;

  const SearchHistoryLoadedState(this.history);

  @override
  List<Object?> get props => [history];
}

final class SearchHistoryErrorState extends SearchState {
  final String message;

  const SearchHistoryErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

final class SearchLoadingState extends SearchState {
  const SearchLoadingState();
}

final class SearchLoadedState extends SearchState {
  final List<SearchEntity> users;
  final PaginationEntity pagination;
  final String currentQuery;

  const SearchLoadedState({
    required this.users,
    required this.pagination,
    required this.currentQuery,
  });

  @override
  List<Object?> get props => [users, pagination, currentQuery];

  SearchLoadedState copyWith({
    List<SearchEntity>? users,
    PaginationEntity? pagination,
    String? currentQuery,
  }) {
    return SearchLoadedState(
      users: users ?? this.users,
      pagination: pagination ?? this.pagination,
      currentQuery: currentQuery ?? this.currentQuery,
    );
  }
}

final class SearchErrorState extends SearchState {
  final String message;

  const SearchErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

final class SearchEmptyState extends SearchState {
  const SearchEmptyState();
}
