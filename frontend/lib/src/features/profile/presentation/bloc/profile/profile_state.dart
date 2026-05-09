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
  final List<PostEntity> posts;
  final String? postsErrorMessage;
  final String? actionErrorMessage;

  const ProfileLoadedState(
    this.profile, {
    this.posts = const [],
    this.postsErrorMessage,
    this.actionErrorMessage,
  });

  ProfileLoadedState copyWith({
    ProfileEntity? profile,
    List<PostEntity>? posts,
    String? postsErrorMessage,
    String? actionErrorMessage,
    bool clearPostsErrorMessage = false,
    bool clearActionErrorMessage = false,
  }) {
    return ProfileLoadedState(
      profile ?? this.profile,
      posts: posts ?? this.posts,
      postsErrorMessage: clearPostsErrorMessage
          ? null
          : postsErrorMessage ?? this.postsErrorMessage,
      actionErrorMessage: clearActionErrorMessage
          ? null
          : actionErrorMessage ?? this.actionErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    profile,
    posts,
    postsErrorMessage,
    actionErrorMessage,
  ];
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
