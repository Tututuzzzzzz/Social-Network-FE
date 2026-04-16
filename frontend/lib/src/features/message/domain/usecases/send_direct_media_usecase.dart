import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message_entity.dart';
import '../repositories/message_repository.dart';
import 'usecase_params.dart';

class SendDirectMediaUseCase
    implements UseCase<MessageActionResultEntity, SendMediaMessageParams> {
  final MessageRepository _repository;

  SendDirectMediaUseCase(this._repository);

  @override
  Future<Either<Failure, MessageActionResultEntity>> call(
    SendMediaMessageParams params,
  ) {
    return _repository.sendDirectMedia(
      conversationId: params.conversationId,
      media: params.media,
      content: params.content,
    );
  }
}
