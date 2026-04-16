import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message_entity.dart';
import '../repositories/message_repository.dart';
import 'usecase_params.dart';

class SendDirectTextUseCase
    implements UseCase<MessageEntity, SendTextMessageParams> {
  final MessageRepository _repository;

  SendDirectTextUseCase(this._repository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendTextMessageParams params) {
    return _repository.sendDirectText(
      conversationId: params.conversationId,
      recipientId: params.recipientId,
      content: params.content,
    );
  }
}
