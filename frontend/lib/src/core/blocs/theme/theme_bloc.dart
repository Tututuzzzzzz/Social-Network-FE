import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/theme_repository.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
	ThemeBloc(this._repository) : super(const ThemeState()) {
		on<ThemeStarted>(_onStarted);
		on<ThemeModeChanged>(_onModeChanged);
	}

	final ThemeRepository _repository;

	Future<void> _onStarted(
		ThemeStarted event,
		Emitter<ThemeState> emit,
	) async {
		emit(state.copyWith(status: ThemeStatus.loading));
		final savedMode = await _repository.getSavedThemeMode();
		emit(
			state.copyWith(
				mode: savedMode,
				status: ThemeStatus.loaded,
			),
		);
	}

	Future<void> _onModeChanged(
		ThemeModeChanged event,
		Emitter<ThemeState> emit,
	) async {
		await _repository.saveThemeMode(event.mode);
		emit(state.copyWith(mode: event.mode));
	}
}

