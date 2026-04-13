part of 'post_form_bloc.dart';

sealed class PostFormEvent extends Equatable {
  const PostFormEvent();

  @override
  List<Object?> get props => [];
}

class PostFormContentChangedEvent extends PostFormEvent {
  final String content;

  const PostFormContentChangedEvent(this.content);

  @override
  List<Object?> get props => [content];
}

class PostFormMediaChangedEvent extends PostFormEvent {
  final List<PostMediaEntity> media;

  const PostFormMediaChangedEvent(this.media);

  @override
  List<Object?> get props => [media];
}

class PostFormResetEvent extends PostFormEvent {}
