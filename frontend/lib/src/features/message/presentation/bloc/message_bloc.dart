import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/usecases/send_direct_text_usecase.dart';
import '../../domain/usecases/usecase_params.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final SendDirectTextUseCase _sendDirectTextUseCase;

  MessageBloc(this._sendDirectTextUseCase) : super(MessageInitial()) {
    on<SendDirectTextEvent>(_onSendDirectText);
  }

  Future<void> _onSendDirectText(
    SendDirectTextEvent event,
    Emitter<MessageState> emit,
  ) async {
    emit(MessageSending());

    final params = SendTextMessageParams(
      conversationId: event.conversationId,
      recipientId: event.recipientId,
      content: event.content,
    );

    final Either result = await _sendDirectTextUseCase(params);

    result.match(
      (l) => emit(const MessageError('Failed to send message')),
      (r) => emit(MessageSent(r)),
    );
  }
}
