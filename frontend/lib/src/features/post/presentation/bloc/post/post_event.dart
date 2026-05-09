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

class PostLikeToggleEvent extends PostEvent {
  final String postId;

  const PostLikeToggleEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}

class PostCommentsChangedEvent extends PostEvent {
  final String postId;
  final List<PostCommentEntity> comments;
  final int commentsCount;

  const PostCommentsChangedEvent({
    required this.postId,
    required this.comments,
    required this.commentsCount,
  });

  @override
  List<Object?> get props => [postId, comments, commentsCount];
}

class PostLocalPostChangedEvent extends PostEvent {
  final PostEntity post;

  const PostLocalPostChangedEvent(this.post);

  @override
  List<Object?> get props => [post];
}

class PostLocalPostDeletedEvent extends PostEvent {
  final String postId;

  const PostLocalPostDeletedEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}
