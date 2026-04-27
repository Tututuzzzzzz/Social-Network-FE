import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_read_status_entity.dart';
import '../repositories/notifications_repository.dart';

class MarkNotificationAsReadUseCase
    implements
        UseCase<NotificationReadStatusEntity, MarkNotificationAsReadParams> {
  final NotificationsRepository _repository;

  const MarkNotificationAsReadUseCase(this._repository);

  @override
  Future<Either<Failure, NotificationReadStatusEntity>> call(
    MarkNotificationAsReadParams params,
  ) {
    return _repository.markNotificationAsRead(params.notificationId);
  }
}

class MarkNotificationAsReadParams extends Equatable {
  final String notificationId;

  const MarkNotificationAsReadParams(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}
