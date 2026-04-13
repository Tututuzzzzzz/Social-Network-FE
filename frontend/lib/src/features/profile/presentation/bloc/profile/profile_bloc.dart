import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/profile_entity.dart';
import '../../../domain/usecases/fetch_profile_items_usecase.dart';
import '../../../domain/usecases/usecase_params.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FetchProfileItemsUseCase _fetchItemsUseCase;

  ProfileBloc(this._fetchItemsUseCase) : super(const ProfileInitialState()) {
    on<ProfileFetchedEvent>(_onFetched);
  }

  Future<void> _onFetched(
    ProfileFetchedEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoadingState());

    final result = await _fetchItemsUseCase.call(
      ProfileQueryParams(page: event.page),
    );

    result.fold(
      (failure) => emit(const ProfileFailureState('Unable to load data')),
      (items) => emit(ProfileSuccessState(items)),
    );
  }
}
