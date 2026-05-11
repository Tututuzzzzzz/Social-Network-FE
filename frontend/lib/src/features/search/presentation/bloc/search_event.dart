part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

final class SearchInitialEvent extends SearchEvent {
  const SearchInitialEvent();
}

final class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

final class SearchUserEvent extends SearchEvent {
  final String name;
  final int page;

  const SearchUserEvent({required this.name, this.page = 1});

  @override
  List<Object?> get props => [name, page];
}

final class LoadMoreSearchEvent extends SearchEvent {
  const LoadMoreSearchEvent();
}

final class GetSearchHistoryEvent extends SearchEvent {
  const GetSearchHistoryEvent();
}

final class SaveSearchQueryEvent extends SearchEvent {
  final SearchHistoryEntry entry;

  const SaveSearchQueryEvent(this.entry);

  @override
  List<Object?> get props => [entry];
}

final class ClearSearchHistoryEvent extends SearchEvent {
  const ClearSearchHistoryEvent();
}
