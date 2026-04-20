import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message_entity.dart';
import '../repositories/message_repository.dart';
import 'usecase_params.dart';

class MarkMessageAsReadUseCase
    implements UseCase<MessageActionResultEntity, MarkMessageAsReadParams> {
  final MessageRepository _repository;

  MarkMessageAsReadUseCase(this._repository);

  @override
  Future<Either<Failure, MessageActionResultEntity>> call(
    MarkMessageAsReadParams params,
  ) {
    return _repository.markMessageAsRead(
      conversationId: params.conversationId,
      messageId: params.messageId,
    );
  }
}
