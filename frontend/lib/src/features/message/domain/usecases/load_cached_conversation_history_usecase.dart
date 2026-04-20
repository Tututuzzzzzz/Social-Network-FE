import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message_entity.dart';
import '../repositories/message_repository.dart';
import 'usecase_params.dart';

class LoadCachedConversationHistoryUseCase
    implements
        UseCase<MessageHistoryPageEntity, ConversationHistoryCacheParams> {
  final MessageRepository _repository;

  LoadCachedConversationHistoryUseCase(this._repository);

  @override
  Future<Either<Failure, MessageHistoryPageEntity>> call(
    ConversationHistoryCacheParams params,
  ) {
    return _repository.loadCachedConversationHistory(
      conversationId: params.conversationId,
    );
  }
}
