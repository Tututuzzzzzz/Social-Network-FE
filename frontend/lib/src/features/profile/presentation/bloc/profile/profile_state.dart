part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitialState extends ProfileState {}

class ProfileLoadingState extends ProfileState {}

enum ProfileFriendRequestStatus { idle, sending, sent, friends, failure }

enum ProfileDirectMessageStatus { idle, opening, failure }

class ProfileLoadedState extends ProfileState {
  final ProfileEntity profile;
  final List<PostEntity> posts;
  final String? postsErrorMessage;
  final String? actionErrorMessage;
  final ProfileFriendRequestStatus? _friendRequestStatus;
  final ProfileDirectMessageStatus? _directMessageStatus;
  final ChatEntity? openedChat;
  final String? directMessageErrorMessage;

  const ProfileLoadedState(
    this.profile, {
    this.posts = const [],
    this.postsErrorMessage,
    this.actionErrorMessage,
    ProfileFriendRequestStatus? friendRequestStatus,
    ProfileDirectMessageStatus? directMessageStatus,
    this.openedChat,
    this.directMessageErrorMessage,
  }) : _friendRequestStatus = friendRequestStatus,
       _directMessageStatus = directMessageStatus;

  ProfileFriendRequestStatus get friendRequestStatus =>
      _friendRequestStatus ?? ProfileFriendRequestStatus.idle;

  ProfileDirectMessageStatus get directMessageStatus =>
      _directMessageStatus ?? ProfileDirectMessageStatus.idle;

  ProfileLoadedState copyWith({
    ProfileEntity? profile,
    List<PostEntity>? posts,
    String? postsErrorMessage,
    String? actionErrorMessage,
    ProfileFriendRequestStatus? friendRequestStatus,
    ProfileDirectMessageStatus? directMessageStatus,
    ChatEntity? openedChat,
    String? directMessageErrorMessage,
    bool clearPostsErrorMessage = false,
    bool clearActionErrorMessage = false,
    bool clearOpenedChat = false,
    bool clearDirectMessageErrorMessage = false,
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
      friendRequestStatus: friendRequestStatus ?? this.friendRequestStatus,
      directMessageStatus: directMessageStatus ?? this.directMessageStatus,
      openedChat: clearOpenedChat ? null : openedChat ?? this.openedChat,
      directMessageErrorMessage: clearDirectMessageErrorMessage
          ? null
          : directMessageErrorMessage ?? this.directMessageErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    profile,
    posts,
    postsErrorMessage,
    actionErrorMessage,
    friendRequestStatus,
    directMessageStatus,
    openedChat,
    directMessageErrorMessage,
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
