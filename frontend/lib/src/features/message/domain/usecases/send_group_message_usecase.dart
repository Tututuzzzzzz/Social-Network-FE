import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message_entity.dart';
import '../repositories/message_repository.dart';
import 'usecase_params.dart';

class SendGroupMessageUseCase
    implements UseCase<MessageEntity, SendMessageParams> {
  final MessageRepository _repository;

  SendGroupMessageUseCase(this._repository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) {
    return _repository.sendGroupMessage(
      conversationId: params.conversationId,
      content: params.content,
      media: params.media,
    );
  }
}
