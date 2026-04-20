import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/logger.dart';
import '../../../domain/entities/post_media_entity.dart';

part 'post_form_event.dart';
part 'post_form_state.dart';

class PostFormBloc extends Bloc<PostFormEvent, PostFormState> {
  PostFormBloc() : super(const PostFormInitialState()) {
    on<PostFormContentChangedEvent>(_onContentChanged);
    on<PostFormMediaChangedEvent>(_onMediaChanged);
    on<PostFormResetEvent>(_onReset);
  }

  Future<void> _onContentChanged(
    PostFormContentChangedEvent event,
    Emitter<PostFormState> emit,
  ) async {
    emit(
      PostFormDataState(inputContent: event.content, inputMedia: state.media),
    );
  }

  Future<void> _onMediaChanged(
    PostFormMediaChangedEvent event,
    Emitter<PostFormState> emit,
  ) async {
    emit(
      PostFormDataState(inputContent: state.content, inputMedia: event.media),
    );
  }

  Future<void> _onReset(
    PostFormResetEvent event,
    Emitter<PostFormState> emit,
  ) async {
    emit(const PostFormInitialState());
  }

  @override
  Future<void> close() {
    logger.i('===== CLOSE PostFormBloc =====');
    return super.close();
  }
}
