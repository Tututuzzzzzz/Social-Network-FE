part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadEvent extends ProfileEvent {}

class ProfileGetEvent extends ProfileEvent {
  final ProfileParams params;

  const ProfileGetEvent(this.params);

  @override
  List<Object?> get props => [params];
}
