import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/chat_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatEntity>>> fetchItems();
  Future<Either<Failure, ChatEntity>> createDirectConversation({
    required String recipientId,
  });
}
