part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitialState extends ProfileState {}

class ProfileLoadingState extends ProfileState {}

class ProfileLoadedState extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoadedState(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileFailureState extends ProfileState {
  final String message;

  const ProfileFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileActionLoadingState extends ProfileState {}

class ProfileActionSuccessState extends ProfileState {
  final String message;

  const ProfileActionSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileActionFailureState extends ProfileState {
  final String message;

  const ProfileActionFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
