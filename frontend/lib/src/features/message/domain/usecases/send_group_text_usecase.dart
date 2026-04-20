import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message_entity.dart';
import '../repositories/message_repository.dart';
import 'usecase_params.dart';

class SendGroupTextUseCase
    implements UseCase<MessageEntity, SendTextMessageParams> {
  final MessageRepository _repository;

  SendGroupTextUseCase(this._repository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendTextMessageParams params) {
    return _repository.sendGroupText(
      conversationId: params.conversationId,
      content: params.content,
    );
  }
}
