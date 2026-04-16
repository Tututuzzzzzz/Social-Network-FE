import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message_entity.dart';
import '../repositories/message_repository.dart';
import 'usecase_params.dart';

class RemoveReactionUseCase
    implements UseCase<MessageActionResultEntity, MessageReactionParams> {
  final MessageRepository _repository;

  RemoveReactionUseCase(this._repository);

  @override
  Future<Either<Failure, MessageActionResultEntity>> call(
    MessageReactionParams params,
  ) {
    return _repository.removeReaction(
      messageId: params.messageId,
      emoji: params.emoji,
    );
  }
}
