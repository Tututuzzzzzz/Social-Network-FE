import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/utils/failure_converter.dart';
import '../../../../../core/utils/logger.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../../domain/usecases/get_profile_usecase.dart';
import '../../../domain/usecases/usecase_params.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;

  ProfileBloc(this._getProfileUseCase) : super(ProfileInitialState()) {
    on<ProfileGetEvent>(_onGet);
  }

  Future<void> _onGet(ProfileGetEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoadingState());

    final result = await _getProfileUseCase.call(event.params);

    result.fold(
      (l) => emit(ProfileFailureState(mapFailureToMessage(l))),
      (r) => emit(ProfileLoadedState(r)),
    );
  }

  @override
  Future<void> close() {
    logger.i('===== CLOSE ProfileBloc =====');
    return super.close();
  }
}
