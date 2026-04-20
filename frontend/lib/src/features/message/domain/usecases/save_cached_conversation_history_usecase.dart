import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/message_repository.dart';
import 'usecase_params.dart';

class SaveCachedConversationHistoryUseCase
    implements UseCase<void, SaveConversationHistoryCacheParams> {
  final MessageRepository _repository;

  SaveCachedConversationHistoryUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(
    SaveConversationHistoryCacheParams params,
  ) {
    return _repository.saveCachedConversationHistory(
      conversationId: params.conversationId,
      page: params.page,
    );
  }
}
