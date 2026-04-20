part of 'post_bloc.dart';

sealed class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitialState extends PostState {}

class PostLoadingState extends PostState {}

class PostLoadedState extends PostState {
  final List<PostEntity> posts;

  const PostLoadedState(this.posts);

  @override
  List<Object?> get props => [posts];
}

class PostFailureState extends PostState {
  final String message;

  const PostFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

class PostActionLoadingState extends PostState {}

class PostActionSuccessState extends PostState {
  final String message;

  const PostActionSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

class PostActionFailureState extends PostState {
  final String message;

  const PostActionFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
