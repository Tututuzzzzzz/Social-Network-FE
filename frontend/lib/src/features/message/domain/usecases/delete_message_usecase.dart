import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message_entity.dart';
import '../repositories/message_repository.dart';
import 'usecase_params.dart';

class DeleteMessageUseCase
    implements UseCase<MessageActionResultEntity, DeleteMessageParams> {
  final MessageRepository _repository;

  DeleteMessageUseCase(this._repository);

  @override
  Future<Either<Failure, MessageActionResultEntity>> call(
    DeleteMessageParams params,
  ) {
    return _repository.deleteMessage(
      conversationId: params.conversationId,
      messageId: params.messageId,
    );
  }
}
