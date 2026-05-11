import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ThemeStatus { initial, loading, loaded }

class ThemeState extends Equatable {
	const ThemeState({
		this.mode = ThemeMode.light,
		this.status = ThemeStatus.initial,
	});

	final ThemeMode mode;
	final ThemeStatus status;

	ThemeState copyWith({ThemeMode? mode, ThemeStatus? status}) {
		return ThemeState(
			mode: mode ?? this.mode,
			status: status ?? this.status,
		);
	}

	@override
	List<Object?> get props => [mode, status];
}

