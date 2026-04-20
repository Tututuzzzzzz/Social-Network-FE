import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message_entity.dart';
import '../repositories/message_repository.dart';
import 'usecase_params.dart';

class MarkAllMessagesAsReadUseCase
    implements UseCase<MessageActionResultEntity, MarkAllMessagesAsReadParams> {
  final MessageRepository _repository;

  MarkAllMessagesAsReadUseCase(this._repository);

  @override
  Future<Either<Failure, MessageActionResultEntity>> call(
    MarkAllMessagesAsReadParams params,
  ) {
    return _repository.markAllMessagesAsRead(
      conversationId: params.conversationId,
      lastMessageId: params.lastMessageId,
    );
  }
}
