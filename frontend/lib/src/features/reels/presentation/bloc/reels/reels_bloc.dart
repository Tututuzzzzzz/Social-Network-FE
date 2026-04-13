import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/reels_entity.dart';
import '../../../domain/usecases/fetch_reels_items_usecase.dart';
import '../../../domain/usecases/usecase_params.dart';

part 'reels_event.dart';
part 'reels_state.dart';

class ReelsBloc extends Bloc<ReelsEvent, ReelsState> {
  final FetchReelsItemsUseCase _fetchItemsUseCase;

  ReelsBloc(this._fetchItemsUseCase) : super(const ReelsInitialState()) {
    on<ReelsFetchedEvent>(_onFetched);
  }

  Future<void> _onFetched(
    ReelsFetchedEvent event,
    Emitter<ReelsState> emit,
  ) async {
    emit(const ReelsLoadingState());

    final result = await _fetchItemsUseCase.call(
      ReelsQueryParams(page: event.page),
    );

    result.fold(
      (failure) => emit(const ReelsFailureState('Unable to load data')),
      (items) => emit(ReelsSuccessState(items)),
    );
  }
}
