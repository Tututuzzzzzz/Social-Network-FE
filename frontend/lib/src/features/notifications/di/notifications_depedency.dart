import '../../../configs/injector/injector_conf.dart';
import '../../../core/api/api_helper.dart';
import '../data/datasources/notification_remote_datasource.dart';
import '../data/repositories/notifications_repository_impl.dart';
import '../domain/repositories/notifications_repository.dart';
import '../domain/usecases/get_notifications_usecase.dart';
import '../domain/usecases/mark_all_notifications_as_read_usecase.dart';
import '../domain/usecases/mark_notification_as_read_usecase.dart';
import '../presentation/bloc/notification_bloc.dart';

class NotificationsDepedency {
  NotificationsDepedency._();

  static void init() {
    if (!getIt.isRegistered<NotificationBloc>()) {
      getIt.registerFactory(
        () => NotificationBloc(
          getIt<GetNotificationsUseCase>(),
          getIt<MarkNotificationAsReadUseCase>(),
          getIt<MarkAllNotificationsAsReadUseCase>(),
        ),
      );
    }

    if (!getIt.isRegistered<GetNotificationsUseCase>()) {
      getIt.registerLazySingleton(
        () => GetNotificationsUseCase(getIt<NotificationsRepository>()),
      );
    }

    if (!getIt.isRegistered<MarkNotificationAsReadUseCase>()) {
      getIt.registerLazySingleton(
        () => MarkNotificationAsReadUseCase(getIt<NotificationsRepository>()),
      );
    }

    if (!getIt.isRegistered<MarkAllNotificationsAsReadUseCase>()) {
      getIt.registerLazySingleton(
        () =>
            MarkAllNotificationsAsReadUseCase(getIt<NotificationsRepository>()),
      );
    }

    if (!getIt.isRegistered<NotificationsRepository>()) {
      getIt.registerLazySingleton<NotificationsRepository>(
        () =>
            NotificationsRepositoryImpl(getIt<NotificationRemoteDataSource>()),
      );
    }

    if (!getIt.isRegistered<NotificationRemoteDataSource>()) {
      getIt.registerLazySingleton<NotificationRemoteDataSource>(
        () => NotificationRemoteDataSourceImpl(getIt<ApiHelper>()),
      );
    }
  }
}
