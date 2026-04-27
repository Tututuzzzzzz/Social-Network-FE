import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_batch_entity.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUseCase
    implements UseCase<NotificationBatchEntity, GetNotificationsParams> {
  final NotificationsRepository _repository;

  const GetNotificationsUseCase(this._repository);

  @override
  Future<Either<Failure, NotificationBatchEntity>> call(
    GetNotificationsParams params,
  ) {
    return _repository.getNotifications(
      page: params.page,
      limit: params.limit,
      unreadOnly: params.unreadOnly,
    );
  }
}

class GetNotificationsParams extends Equatable {
  final int page;
  final int limit;
  final bool unreadOnly;

  const GetNotificationsParams({
    this.page = 1,
    this.limit = 20,
    this.unreadOnly = false,
  });

  @override
  List<Object?> get props => [page, limit, unreadOnly];
}
