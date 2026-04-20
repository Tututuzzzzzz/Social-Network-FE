part of 'post_form_bloc.dart';

sealed class PostFormState extends Equatable {
  final String content;
  final List<PostMediaEntity> media;
  final bool hasContent;
  final bool hasMedia;
  final bool isValid;

  const PostFormState({
    required this.content,
    required this.media,
    required this.hasContent,
    required this.hasMedia,
    required this.isValid,
  });

  @override
  List<Object?> get props => [content, media, hasContent, hasMedia, isValid];
}

class PostFormInitialState extends PostFormState {
  const PostFormInitialState()
    : super(
        content: '',
        media: const [],
        hasContent: false,
        hasMedia: false,
        isValid: false,
      );
}

class PostFormDataState extends PostFormState {
  final String inputContent;
  final List<PostMediaEntity> inputMedia;

  PostFormDataState({required this.inputContent, required this.inputMedia})
    : super(
        content: inputContent,
        media: inputMedia,
        hasContent: inputContent.trim().isNotEmpty,
        hasMedia: inputMedia.isNotEmpty,
        isValid: inputContent.trim().isNotEmpty || inputMedia.isNotEmpty,
      );

  @override
  List<Object?> get props => [
    inputContent,
    inputMedia,
    hasContent,
    hasMedia,
    isValid,
  ];
}
