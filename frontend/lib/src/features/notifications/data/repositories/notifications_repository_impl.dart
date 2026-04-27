import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_batch_entity.dart';
import '../../domain/entities/notification_read_status_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  const NotificationsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, NotificationBatchEntity>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final result = await _remoteDataSource.getNotifications(
        page: page,
        limit: limit,
        unreadOnly: unreadOnly,
      );
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, NotificationReadStatusEntity>>
  markAllNotificationsAsRead() async {
    try {
      final result = await _remoteDataSource.markAllNotificationsAsRead();
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, NotificationReadStatusEntity>> markNotificationAsRead(
    String notificationId,
  ) async {
    try {
      final result = await _remoteDataSource.markNotificationAsRead(
        notificationId,
      );
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
