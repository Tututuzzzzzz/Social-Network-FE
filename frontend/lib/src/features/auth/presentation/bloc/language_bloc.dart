import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/language_repository.dart';

// Events
abstract class LanguageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LanguageStarted extends LanguageEvent {}

class LanguageChanged extends LanguageEvent {
  final Locale locale;
  LanguageChanged(this.locale);

  @override
  List<Object?> get props => [locale];
}

// State
enum LanguageStatus { initial, loading, loaded }

class LanguageState extends Equatable {
  final Locale? locale;
  final LanguageStatus status;

  const LanguageState({
    this.locale,
    this.status = LanguageStatus.initial,
  });

  LanguageState copyWith({
    Locale? locale,
    LanguageStatus? status,
  }) {
    return LanguageState(
      locale: locale ?? this.locale,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [locale, status];
}

// Bloc
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final LanguageRepository _repository;

  LanguageBloc(this._repository) : super(const LanguageState()) {
    on<LanguageStarted>(_onStarted);
    on<LanguageChanged>(_onChanged);
  }

  Future<void> _onStarted(
    LanguageStarted event,
    Emitter<LanguageState> emit,
  ) async {
    emit(state.copyWith(status: LanguageStatus.loading));
    final savedLocale = await _repository.getSavedLocale();
    emit(state.copyWith(
      locale: savedLocale,
      status: LanguageStatus.loaded,
    ));
  }

  Future<void> _onChanged(
    LanguageChanged event,
    Emitter<LanguageState> emit,
  ) async {
    await _repository.saveLocale(event.locale);
    emit(state.copyWith(locale: event.locale));
  }
}
