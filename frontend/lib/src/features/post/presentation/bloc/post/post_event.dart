part of 'post_bloc.dart';

sealed class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class PostLoadEvent extends PostEvent {}

class PostCreateEvent extends PostEvent {
  final CreatePostParams params;

  const PostCreateEvent(this.params);

  @override
  List<Object?> get props => [params];
}

class PostUpdateEvent extends PostEvent {
  final UpdatePostParams params;

  const PostUpdateEvent(this.params);

  @override
  List<Object?> get props => [params];
}

class PostDeleteEvent extends PostEvent {
  final DeletePostParams params;

  const PostDeleteEvent(this.params);

  @override
  List<Object?> get props => [params];
}
