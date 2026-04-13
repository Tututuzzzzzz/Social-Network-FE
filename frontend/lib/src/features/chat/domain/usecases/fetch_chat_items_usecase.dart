import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';
import 'usecase_params.dart';

class FetchChatItemsUseCase
    implements UseCase<List<ChatEntity>, ChatQueryParams> {
  final ChatRepository _repository;

  FetchChatItemsUseCase(this._repository);

  @override
  Future<Either<Failure, List<ChatEntity>>> call(ChatQueryParams params) {
    return _repository.fetchItems();
  }
}
