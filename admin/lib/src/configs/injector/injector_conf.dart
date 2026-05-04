import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/api/api_client.dart';
import '../../core/api/session_expiration_notifier.dart';
import '../../core/cache/session_storage.dart';
import '../../features/admin/di/admin_dependency.dart';
import '../../features/auth/di/auth_dependency.dart';
import '../../features/post/di/post_dependency.dart';
import '../../features/report/di/report_dependency.dart';
import '../../features/user/di/user_dependency.dart';
import 'injector.dart';

Future<void> configureDependencies() async {
  if (injector.isRegistered<ApiClient>()) {
    return;
  }

  injector
    ..registerLazySingleton<Dio>(Dio.new)
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    )
    ..registerLazySingleton<SessionStorage>(
      () => SessionStorage(injector<FlutterSecureStorage>()),
    )
    ..registerLazySingleton<SessionExpirationNotifier>(
      SessionExpirationNotifier.new,
    )
    ..registerLazySingleton<ApiClient>(
      () => ApiClient(
        injector<Dio>(),
        injector<SessionStorage>(),
        injector<SessionExpirationNotifier>(),
      ),
    );

  initAuthDependency();
  initPostDependency();
  initUserDependency();
  initReportDependency();
  initAdminDependency();
}
