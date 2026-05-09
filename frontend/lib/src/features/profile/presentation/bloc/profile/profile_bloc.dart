import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/failure_converter.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../chat/domain/entities/chat_entity.dart';
import '../../../../chat/domain/usecases/create_direct_conversation_usecase.dart';
import '../../../../chat/domain/usecases/usecase_params.dart'
    as chat_usecase_params;
import '../../../../friend/domain/usecases/get_all_friend_ids.dart';
import '../../../../friend/domain/usecases/send_friend_request.dart';
import '../../../../post/domain/entities/post_entity.dart';
import '../../../../post/domain/usecases/toggle_like_post_usecase.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../../domain/usecases/get_profile_usecase.dart';
import '../../../domain/usecases/get_user_posts_usecase.dart';
import '../../../domain/usecases/update_profile_usecase.dart';
import '../../../domain/usecases/usecase_params.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final GetUserPostsUseCase _getUserPostsUseCase;
  final ToggleLikePostUseCase _toggleLikePostUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final GetAllFriendIds _getAllFriendIds;
  final SendFriendRequest _sendFriendRequest;
  final CreateDirectConversationUseCase _createDirectConversationUseCase;

  ProfileBloc(
    this._getProfileUseCase,
    this._getUserPostsUseCase,
    this._toggleLikePostUseCase,
    this._updateProfileUseCase,
    this._getAllFriendIds,
    this._sendFriendRequest,
    this._createDirectConversationUseCase,
  ) : super(ProfileInitialState()) {
    on<ProfileGetEvent>(_onGet);
    on<ProfilePostLikeToggleEvent>(_onPostLikeToggle);
    on<ProfileUpdateEvent>(_onUpdate);
    on<ProfileFriendRequestSendEvent>(_onSendFriendRequest);
    on<ProfileDirectMessageOpenEvent>(_onOpenDirectMessage);
    on<ProfileActionFeedbackClearedEvent>(_onClearActionFeedback);
  }

  Future<void> _onGet(ProfileGetEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoadingState());

    final profileResult = await _getProfileUseCase.call(event.params);

    await profileResult.fold(
      (failure) async =>
          emit(ProfileFailureState(mapFailureToMessage(failure))),
      (profile) async {
        final friendshipStatus = await _resolveFriendshipStatus(profile.id);
        final postsResult = await _getUserPostsUseCase.call(
          GetUserPostsParams(userId: event.params.userId),
        );

        postsResult.fold(
          (failure) => emit(
            ProfileLoadedState(
              profile,
              postsErrorMessage: mapFailureToMessage(failure),
              friendRequestStatus: friendshipStatus,
            ),
          ),
          (posts) => emit(
            ProfileLoadedState(
              profile,
              posts: posts,
              friendRequestStatus: friendshipStatus,
            ),
          ),
        );
      },
    );
  }

  Future<ProfileFriendRequestStatus> _resolveFriendshipStatus(
    String targetUserId,
  ) async {
    final normalizedTargetUserId = targetUserId.trim();
    if (normalizedTargetUserId.isEmpty) {
      return ProfileFriendRequestStatus.idle;
    }

    try {
      final friendIds = await _getAllFriendIds();
      final isFriend = friendIds.any(
        (friendId) => friendId.trim() == normalizedTargetUserId,
      );
      return isFriend
          ? ProfileFriendRequestStatus.friends
          : ProfileFriendRequestStatus.idle;
    } catch (error, stackTrace) {
      logger.e(error, stackTrace: stackTrace);
      return ProfileFriendRequestStatus.idle;
    }
  }

  Future<void> _onPostLikeToggle(
    ProfilePostLikeToggleEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoadedState) {
      return;
    }

    final result = await _toggleLikePostUseCase.call(
      ToggleLikePostParams(postId: event.postId),
    );

    result.fold(
      (failure) => emit(
        currentState.copyWith(actionErrorMessage: mapFailureToMessage(failure)),
      ),
      (updatedPost) {
        final updatedPosts = currentState.posts
            .map((post) => post.id == updatedPost.id ? updatedPost : post)
            .toList();

        emit(
          currentState.copyWith(
            posts: updatedPosts,
            clearActionErrorMessage: true,
          ),
        );
      },
    );
  }

  Future<void> _onUpdate(
    ProfileUpdateEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileActionLoadingState());

    final result = await _updateProfileUseCase.call(event.params);

    result.fold(
      (failure) =>
          emit(ProfileActionFailureState(mapFailureToMessage(failure))),
      (_) => emit(const ProfileActionSuccessState('Profile updated')),
    );
  }

  Future<void> _onSendFriendRequest(
    ProfileFriendRequestSendEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoadedState ||
        currentState.friendRequestStatus ==
            ProfileFriendRequestStatus.sending ||
        currentState.friendRequestStatus == ProfileFriendRequestStatus.sent ||
        currentState.friendRequestStatus ==
            ProfileFriendRequestStatus.friends) {
      return;
    }

    final targetUserId = event.userId.trim();
    if (targetUserId.isEmpty) {
      return;
    }

    emit(
      currentState.copyWith(
        friendRequestStatus: ProfileFriendRequestStatus.sending,
        clearActionErrorMessage: true,
      ),
    );

    try {
      await _sendFriendRequest(targetUserId);
      final latestState = state;
      if (latestState is ProfileLoadedState) {
        final latestFriendshipStatus = await _resolveFriendshipStatus(
          targetUserId,
        );
        emit(
          latestState.copyWith(
            friendRequestStatus:
                latestFriendshipStatus == ProfileFriendRequestStatus.friends
                ? ProfileFriendRequestStatus.friends
                : ProfileFriendRequestStatus.sent,
            clearActionErrorMessage: true,
          ),
        );
      }
    } catch (_) {
      final latestState = state;
      if (latestState is ProfileLoadedState) {
        final latestFriendshipStatus = await _resolveFriendshipStatus(
          targetUserId,
        );
        emit(
          latestState.copyWith(
            friendRequestStatus:
                latestFriendshipStatus == ProfileFriendRequestStatus.friends
                ? ProfileFriendRequestStatus.friends
                : ProfileFriendRequestStatus.failure,
          ),
        );
      }
    }
  }

  Future<void> _onOpenDirectMessage(
    ProfileDirectMessageOpenEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoadedState ||
        currentState.directMessageStatus ==
            ProfileDirectMessageStatus.opening) {
      return;
    }

    final targetUserId = event.userId.trim();
    if (targetUserId.isEmpty) {
      return;
    }

    emit(
      currentState.copyWith(
        directMessageStatus: ProfileDirectMessageStatus.opening,
        clearOpenedChat: true,
        clearDirectMessageErrorMessage: true,
      ),
    );

    final result = await _createDirectConversationUseCase(
      chat_usecase_params.CreateDirectConversationParams(
        recipientId: targetUserId,
      ),
    );

    final latestState = state;
    if (latestState is! ProfileLoadedState) {
      return;
    }

    result.fold(
      (failure) => emit(
        latestState.copyWith(
          directMessageStatus: ProfileDirectMessageStatus.failure,
          directMessageErrorMessage: mapFailureToMessage(failure),
          clearOpenedChat: true,
        ),
      ),
      (chat) => emit(
        latestState.copyWith(
          directMessageStatus: ProfileDirectMessageStatus.idle,
          openedChat: chat,
          clearDirectMessageErrorMessage: true,
        ),
      ),
    );
  }

  void _onClearActionFeedback(
    ProfileActionFeedbackClearedEvent event,
    Emitter<ProfileState> emit,
  ) {
    final currentState = state;
    if (currentState is! ProfileLoadedState) {
      return;
    }

    emit(
      currentState.copyWith(
        friendRequestStatus:
            currentState.friendRequestStatus ==
                ProfileFriendRequestStatus.failure
            ? ProfileFriendRequestStatus.idle
            : currentState.friendRequestStatus,
        directMessageStatus:
            currentState.directMessageStatus ==
                ProfileDirectMessageStatus.failure
            ? ProfileDirectMessageStatus.idle
            : currentState.directMessageStatus,
        clearActionErrorMessage: true,
        clearOpenedChat: true,
        clearDirectMessageErrorMessage: true,
      ),
    );
  }

  @override
  Future<void> close() {
    logger.i('===== CLOSE ProfileBloc =====');
    return super.close();
  }
}
