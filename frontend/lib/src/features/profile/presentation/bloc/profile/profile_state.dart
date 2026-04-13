part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitialState extends ProfileState {
  const ProfileInitialState();
}

class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState();
}

class ProfileSuccessState extends ProfileState {
  final List<ProfileEntity> items;

  const ProfileSuccessState(this.items);

  @override
  List<Object?> get props => [items];
}

class ProfileFailureState extends ProfileState {
  final String message;

  const ProfileFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
