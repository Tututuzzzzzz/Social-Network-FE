import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/home_entity.dart';
import '../../../domain/usecases/fetch_home_items_usecase.dart';
import '../../../domain/usecases/usecase_params.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchHomeItemsUseCase _fetchItemsUseCase;

  HomeBloc(this._fetchItemsUseCase) : super(const HomeInitialState()) {
    on<HomeFetchedEvent>(_onFetched);
  }

  Future<void> _onFetched(
    HomeFetchedEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoadingState());

    final result = await _fetchItemsUseCase.call(
      HomeQueryParams(page: event.page),
    );

    result.fold(
      (failure) => emit(const HomeFailureState('Unable to load data')),
      (items) => emit(HomeSuccessState(items)),
    );
  }
}
