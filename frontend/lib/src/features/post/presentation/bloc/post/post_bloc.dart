import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/cache/secure_local_storage.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/utils/failure_converter.dart';
import '../../../../../core/utils/logger.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/entities/post_comment_entity.dart';
import '../../../domain/utils/post_list_mutations.dart';
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
  final SecureLocalStorage _secureLocalStorage;
  List<PostEntity> _cachedPosts = const [];

  PostBloc(
    this._createPostUseCase,
    this._deletePostUseCase,
    this._getPostUseCase,
    this._updatePostUseCase,
    this._toggleLikePostUseCase,
    this._secureLocalStorage,
  ) : super(PostInitialState()) {
    on<PostLoadEvent>(_onLoad);
    on<PostCreateEvent>(_onCreate);
    on<PostUpdateEvent>(_onUpdate);
    on<PostDeleteEvent>(_onDelete);
    on<PostLikeToggleEvent>(_onLikeToggle);
    on<PostCommentsChangedEvent>(_onCommentsChanged);
    on<PostLocalPostChangedEvent>(_onLocalPostChanged);
    on<PostLocalPostDeletedEvent>(_onLocalPostDeleted);
  }

  Future<void> _onLoad(PostLoadEvent event, Emitter<PostState> emit) async {
    emit(PostLoadingState());

    final result = await _getPostUseCase.call(NoParams());

    result.fold(
      (l) => emit(PostFailureState(mapFailureToMessage(l))),
      (r) => _emitLoadedPosts(emit, r),
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
    final previousPosts = _currentPosts;
    emit(PostActionLoadingState());

    final result = await _updatePostUseCase.call(event.params);

    result.fold((l) => emit(PostActionFailureState(mapFailureToMessage(l))), (
      r,
    ) {
      if (previousPosts.isNotEmpty) {
        _emitLoadedPosts(emit, _applyPostUpdate(previousPosts, event.params));
      }
      add(PostLoadEvent());
    });
  }

  Future<void> _onDelete(PostDeleteEvent event, Emitter<PostState> emit) async {
    final previousPosts = _currentPosts;
    emit(PostActionLoadingState());

    final result = await _deletePostUseCase.call(event.params);

    result.fold((l) => emit(PostActionFailureState(mapFailureToMessage(l))), (
      r,
    ) {
      if (previousPosts.isNotEmpty) {
        _emitLoadedPosts(emit, _removePost(previousPosts, event.params.postId));
      }
      add(PostLoadEvent());
    });
  }

  Future<void> _onLikeToggle(
    PostLikeToggleEvent event,
    Emitter<PostState> emit,
  ) async {
    final previousPosts = _currentPosts;

    final currentUserId = await _resolveCurrentUserId();
    if (previousPosts.isNotEmpty && currentUserId.isNotEmpty) {
      final optimisticPosts = togglePostLikeInList(
        posts: previousPosts,
        postId: event.postId,
        currentUserId: currentUserId,
      );

      if (optimisticPosts != null) {
        _emitLoadedPosts(emit, optimisticPosts);
      }
    } else {
      emit(PostActionLoadingState());
    }

    final result = await _toggleLikePostUseCase.call(
      ToggleLikePostParams(postId: event.postId),
    );

    result.fold(
      (l) {
        if (previousPosts.isNotEmpty) {
          _emitLoadedPosts(emit, previousPosts);
        }

        emit(PostActionFailureState(mapFailureToMessage(l)));
      },
      (updatedPost) {
        final posts = _currentPosts;
        if (posts.isNotEmpty) {
          _emitLoadedPosts(emit, replacePostInList(posts, updatedPost));
          return;
        }

        emit(PostActionSuccessState(''));
      },
    );
  }

  void _onCommentsChanged(
    PostCommentsChangedEvent event,
    Emitter<PostState> emit,
  ) {
    final posts = _currentPosts;
    if (posts.isEmpty || event.postId.trim().isEmpty) return;

    var found = false;
    final nextPosts = posts.map((post) {
      if (post.id != event.postId) return post;
      found = true;
      return post.copyWith(
        comments: List<PostCommentEntity>.unmodifiable(event.comments),
        commentsCount: event.commentsCount,
      );
    }).toList();

    if (found) {
      _emitLoadedPosts(emit, nextPosts);
    }
  }

  void _onLocalPostChanged(
    PostLocalPostChangedEvent event,
    Emitter<PostState> emit,
  ) {
    final posts = _currentPosts;
    if (posts.isEmpty || event.post.id.trim().isEmpty) return;

    final nextPosts = replacePostInList(posts, event.post);
    if (!identical(nextPosts, posts)) {
      _emitLoadedPosts(emit, nextPosts);
    }
  }

  void _onLocalPostDeleted(
    PostLocalPostDeletedEvent event,
    Emitter<PostState> emit,
  ) {
    final posts = _currentPosts;
    if (posts.isEmpty || event.postId.trim().isEmpty) return;
    _emitLoadedPosts(emit, _removePost(posts, event.postId));
  }

  Future<String> _resolveCurrentUserId() async {
    final storedUserId = await _secureLocalStorage.load(key: 'user_id');
    return storedUserId.trim();
  }

  List<PostEntity> _applyPostUpdate(
    List<PostEntity> posts,
    UpdatePostParams params,
  ) {
    return posts.map((post) {
      if (post.id != params.postId) return post;
      return post.copyWith(
        content: params.hasContentField ? params.content : post.content,
        media: params.hasMediaField ? params.media ?? const [] : post.media,
      );
    }).toList();
  }

  List<PostEntity> _removePost(List<PostEntity> posts, String postId) {
    return posts.where((post) => post.id != postId).toList();
  }

  List<PostEntity> get _currentPosts {
    final currentState = state;
    if (currentState is PostLoadedState) {
      return currentState.posts;
    }
    return _cachedPosts;
  }

  void _emitLoadedPosts(Emitter<PostState> emit, List<PostEntity> posts) {
    _cachedPosts = List<PostEntity>.unmodifiable(posts);
    emit(PostLoadedState(_cachedPosts));
  }

  @override
  Future<void> close() {
    logger.i('===== CLOSE PostBloc =====');
    return super.close();
  }
}
