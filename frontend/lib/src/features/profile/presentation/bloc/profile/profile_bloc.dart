import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/failure_converter.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../post/domain/entities/post_entity.dart';
import '../../../../post/domain/usecases/toggle_like_post_usecase.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../../domain/usecases/get_profile_usecase.dart';
import '../../../domain/usecases/get_user_posts_usecase.dart';
import '../../../domain/usecases/usecase_params.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final GetUserPostsUseCase _getUserPostsUseCase;
  final ToggleLikePostUseCase _toggleLikePostUseCase;

  ProfileBloc(
    this._getProfileUseCase,
    this._getUserPostsUseCase,
    this._toggleLikePostUseCase,
  ) : super(ProfileInitialState()) {
    on<ProfileGetEvent>(_onGet);
    on<ProfilePostLikeToggleEvent>(_onPostLikeToggle);
  }

  Future<void> _onGet(ProfileGetEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoadingState());

    final profileResult = await _getProfileUseCase.call(event.params);

    await profileResult.fold(
      (failure) async =>
          emit(ProfileFailureState(mapFailureToMessage(failure))),
      (profile) async {
        final postsResult = await _getUserPostsUseCase.call(
          GetUserPostsParams(userId: event.params.userId),
        );

        postsResult.fold(
          (failure) => emit(
            ProfileLoadedState(
              profile,
              postsErrorMessage: mapFailureToMessage(failure),
            ),
          ),
          (posts) => emit(ProfileLoadedState(profile, posts: posts)),
        );
      },
    );
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

  @override
  Future<void> close() {
    logger.i('===== CLOSE ProfileBloc =====');
    return super.close();
  }
}
