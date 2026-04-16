import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';
import 'usecase_params.dart';

class CreateDirectConversationUseCase
    implements UseCase<ChatEntity, CreateDirectConversationParams> {
  final ChatRepository _repository;

  CreateDirectConversationUseCase(this._repository);

  @override
  Future<Either<Failure, ChatEntity>> call(
    CreateDirectConversationParams params,
  ) {
    return _repository.createDirectConversation(
      recipientId: params.recipientId,
    );
  }
}
