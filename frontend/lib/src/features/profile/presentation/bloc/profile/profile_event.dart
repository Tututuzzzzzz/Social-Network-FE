part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileFetchedEvent extends ProfileEvent {
  final int page;

  const ProfileFetchedEvent({this.page = 1});

  @override
  List<Object?> get props => [page];
}
