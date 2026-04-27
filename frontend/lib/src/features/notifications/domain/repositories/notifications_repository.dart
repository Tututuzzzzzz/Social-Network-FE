import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/notification_batch_entity.dart';
import '../entities/notification_read_status_entity.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, NotificationBatchEntity>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  });

  Future<Either<Failure, NotificationReadStatusEntity>> markNotificationAsRead(
    String notificationId,
  );

  Future<Either<Failure, NotificationReadStatusEntity>>
  markAllNotificationsAsRead();
}
