import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/models.dart';

abstract class NotificationRemoteDataSource {
  Future<GetNotificationsModel> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  });

  Future<MarkNotificationReadModel> markNotificationAsRead(String id);

  Future<MarkAllNotificationsReadModel> markAllNotificationsAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiHelper _apiHelper;

  const NotificationRemoteDataSourceImpl(this._apiHelper);

  @override
  Future<GetNotificationsModel> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final query = Uri(
        queryParameters: {
          'page': '$page',
          'limit': '$limit',
          'unreadOnly': '$unreadOnly',
        },
      ).query;

      final result = await _apiHelper.execute(
        method: Method.get,
        url: '${ApiConstants.notifications}?$query',
      );

      return GetNotificationsModel.fromJson(result);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<MarkNotificationReadModel> markNotificationAsRead(String id) async {
    try {
      final result = await _apiHelper.execute(
        method: Method.patch,
        url: ApiConstants.notificationRead(id),
      );
      return MarkNotificationReadModel.fromJson(result);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<MarkAllNotificationsReadModel> markAllNotificationsAsRead() async {
    try {
      final result = await _apiHelper.execute(
        method: Method.patch,
        url: ApiConstants.notificationsReadAll,
      );
      return MarkAllNotificationsReadModel.fromJson(result);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }
}
