import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message_entity.dart';
import '../repositories/message_repository.dart';
import 'usecase_params.dart';

class FetchConversationHistoryUseCase
    implements
        UseCase<MessageHistoryPageEntity, FetchConversationHistoryParams> {
  final MessageRepository _repository;

  FetchConversationHistoryUseCase(this._repository);

  @override
  Future<Either<Failure, MessageHistoryPageEntity>> call(
    FetchConversationHistoryParams params,
  ) {
    return _repository.fetchConversationHistory(
      conversationId: params.conversationId,
      limit: params.limit,
      cursor: params.cursor,
    );
  }
}
