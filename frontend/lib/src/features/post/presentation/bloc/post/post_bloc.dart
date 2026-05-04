import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/utils/failure_converter.dart';
import '../../../../../core/utils/logger.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/usecases/create_post_usecase.dart';
import '../../../domain/usecases/delete_post_usecase.dart';
import '../../../domain/usecases/get_post_usecase.dart';
import '../../../domain/usecases/toggle_like_post_usecase.dart';
import '../../../domain/usecases/update_post_usecase.dart';
import '../../../domain/usecases/usecase_params.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostUseCase _getPostUseCase;
  final CreatePostUseCase _createPostUseCase;
  final UpdatePostUseCase _updatePostUseCase;
  final DeletePostUseCase _deletePostUseCase;
  final ToggleLikePostUseCase _toggleLikePostUseCase;

  PostBloc(
    this._createPostUseCase,
    this._deletePostUseCase,
    this._getPostUseCase,
    this._updatePostUseCase,
    this._toggleLikePostUseCase,
  ) : super(PostInitialState()) {
    on<PostLoadEvent>(_onLoad);
    on<PostCreateEvent>(_onCreate);
    on<PostUpdateEvent>(_onUpdate);
    on<PostDeleteEvent>(_onDelete);
    on<PostLikeToggleEvent>(_onLikeToggle);
  }

  Future<void> _onLoad(PostLoadEvent event, Emitter<PostState> emit) async {
    emit(PostLoadingState());

    final result = await _getPostUseCase.call(NoParams());

    result.fold(
      (l) => emit(PostFailureState(mapFailureToMessage(l))),
      (r) => emit(PostLoadedState(r)),
    );
  }

  Future<void> _onCreate(PostCreateEvent event, Emitter<PostState> emit) async {
    emit(PostActionLoadingState());

    final result = await _createPostUseCase.call(event.params);

    result.fold(
      (l) => emit(PostActionFailureState(mapFailureToMessage(l))),
      (r) => add(PostLoadEvent()),
    );
  }

  Future<void> _onUpdate(PostUpdateEvent event, Emitter<PostState> emit) async {
    emit(PostActionLoadingState());

    final result = await _updatePostUseCase.call(event.params);

    result.fold(
      (l) => emit(PostActionFailureState(mapFailureToMessage(l))),
      (r) => add(PostLoadEvent()),
    );
  }

  Future<void> _onDelete(PostDeleteEvent event, Emitter<PostState> emit) async {
    emit(PostActionLoadingState());

    final result = await _deletePostUseCase.call(event.params);

    result.fold(
      (l) => emit(PostActionFailureState(mapFailureToMessage(l))),
      (r) => add(PostLoadEvent()),
    );
  }

  Future<void> _onLikeToggle(
    PostLikeToggleEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(PostActionLoadingState());

    final result = await _toggleLikePostUseCase.call(
      ToggleLikePostParams(postId: event.postId),
    );

    result.fold(
      (l) => emit(PostActionFailureState(mapFailureToMessage(l))),
      (r) => add(PostLoadEvent()),
    );
  }

  @override
  Future<void> close() {
    logger.i('===== CLOSE PostBloc =====');
    return super.close();
  }
}
