import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/api/api_client.dart';
import '../../core/cache/session_storage.dart';
import '../../features/admin/di/admin_dependency.dart';
import '../../features/auth/di/auth_dependency.dart';
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
    ..registerLazySingleton<ApiClient>(
      () => ApiClient(injector<Dio>(), injector<SessionStorage>()),
    );

  initAuthDependency();
  initAdminDependency();
}
