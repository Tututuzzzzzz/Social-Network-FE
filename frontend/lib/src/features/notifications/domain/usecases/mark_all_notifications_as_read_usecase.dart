import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_read_status_entity.dart';
import '../repositories/notifications_repository.dart';

class MarkAllNotificationsAsReadUseCase
    implements UseCase<NotificationReadStatusEntity, NoParams> {
  final NotificationsRepository _repository;

  const MarkAllNotificationsAsReadUseCase(this._repository);

  @override
  Future<Either<Failure, NotificationReadStatusEntity>> call(NoParams params) {
    return _repository.markAllNotificationsAsRead();
  }
}
