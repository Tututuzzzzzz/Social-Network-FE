import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/failure_converter.dart';
import '../../domain/entities/search_entity.dart';
import '../../domain/usecases/search_usecase.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUserUseCase searchUserUseCase;
  final GetSearchHistoryUseCase getSearchHistoryUseCase;
  final SaveSearchQueryUseCase saveSearchQueryUseCase;
  final ClearSearchHistoryUseCase clearSearchHistoryUseCase;

  String _currentQuery = '';
  List<SearchEntity> _allUsers = [];

  SearchBloc({
    required this.searchUserUseCase,
    required this.getSearchHistoryUseCase,
    required this.saveSearchQueryUseCase,
    required this.clearSearchHistoryUseCase,
  }) : super(const SearchInitialState()) {
    on<SearchInitialEvent>(_onInitial);
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchUserEvent>(_onSearchUser);
    on<LoadMoreSearchEvent>(_onLoadMore);
    on<GetSearchHistoryEvent>(_onGetSearchHistory);
    on<SaveSearchQueryEvent>(_onSaveSearchQuery);
    on<ClearSearchHistoryEvent>(_onClearSearchHistory);
  }

  Future<void> _onInitial(
    SearchInitialEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchHistoryLoadingState());
    final result = await getSearchHistoryUseCase();
    result.fold(
      (failure) => emit(SearchHistoryErrorState(mapFailureToMessage(failure))),
      (history) => emit(SearchHistoryLoadedState(history)),
    );
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    _currentQuery = event.query;
    if (event.query.isEmpty) {
      // Show search history
      final result = await getSearchHistoryUseCase();
      result.fold(
        (failure) => emit(SearchHistoryErrorState(mapFailureToMessage(failure))),
        (history) => emit(SearchHistoryLoadedState(history)),
      );
    }
  }

  Future<void> _onSearchUser(
    SearchUserEvent event,
    Emitter<SearchState> emit,
  ) async {
    final normalized = event.name.trim();
    if (normalized.isEmpty) {
      add(const GetSearchHistoryEvent());
      return;
    }

    _currentQuery = normalized;
    _allUsers = [];

    emit(const SearchLoadingState());

    final result = await searchUserUseCase(
      name: normalized,
      page: event.page,
      limit: 20,
    );

    result.fold(
      (failure) => emit(SearchErrorState(mapFailureToMessage(failure))),
      (response) {
        _allUsers = response.data;
        if (response.data.isEmpty) {
          emit(const SearchEmptyState());
        } else {
          emit(SearchLoadedState(
            users: response.data,
            pagination: response.pagination,
            currentQuery: normalized,
          ));
          // Save search query to history
          add(SaveSearchQueryEvent(SearchHistoryEntry.query(normalized)));
        }
      },
    );
  }

  Future<void> _onLoadMore(
    LoadMoreSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (state is SearchLoadedState) {
      final currentState = state as SearchLoadedState;
      if (currentState.pagination.hasMore) {
        final nextPage = currentState.pagination.page + 1;

        final result = await searchUserUseCase(
          name: _currentQuery,
          page: nextPage,
          limit: 20,
        );

        result.fold(
          (failure) => emit(SearchErrorState(mapFailureToMessage(failure))),
          (response) {
            _allUsers.addAll(response.data);
            emit(SearchLoadedState(
              users: _allUsers,
              pagination: response.pagination,
              currentQuery: _currentQuery,
            ));
          },
        );
      }
    }
  }

  Future<void> _onGetSearchHistory(
    GetSearchHistoryEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchHistoryLoadingState());
    final result = await getSearchHistoryUseCase();
    result.fold(
      (failure) => emit(SearchHistoryErrorState(mapFailureToMessage(failure))),
      (history) => emit(SearchHistoryLoadedState(history)),
    );
  }

  Future<void> _onSaveSearchQuery(
    SaveSearchQueryEvent event,
    Emitter<SearchState> emit,
  ) async {
    await saveSearchQueryUseCase(event.entry);
  }

  Future<void> _onClearSearchHistory(
    ClearSearchHistoryEvent event,
    Emitter<SearchState> emit,
  ) async {
    final result = await clearSearchHistoryUseCase();
    result.fold(
      (failure) => emit(SearchHistoryErrorState(mapFailureToMessage(failure))),
      (_) => emit(const SearchHistoryLoadedState([])),
    );
  }
}
