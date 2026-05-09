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

class ProfilePostLikeToggleEvent extends ProfileEvent {
  final String postId;

  const ProfilePostLikeToggleEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}

class ProfileUpdateEvent extends ProfileEvent {
  final UpdateProfileParams params;

  const ProfileUpdateEvent(this.params);

  @override
  List<Object?> get props => [params];
}

class ProfileFriendRequestSendEvent extends ProfileEvent {
  final String userId;

  const ProfileFriendRequestSendEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ProfileDirectMessageOpenEvent extends ProfileEvent {
  final String userId;

  const ProfileDirectMessageOpenEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ProfileActionFeedbackClearedEvent extends ProfileEvent {}
