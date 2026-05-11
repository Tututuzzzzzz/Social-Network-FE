import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../../core/config/env_config.dart';
import 'injector.dart';
import '../../features/search/di/search_dependency.dart';
import '../../core/blocs/theme/theme_bloc.dart';
import '../../core/theme/theme_repository.dart';

final getIt = GetIt.I;

void configureDepedencies() {
  AuthDepedency.init();
  PostDepedency.init();
  ChatDependency.init();
  FriendDependency.init();
  MessageDependency.init();
  NotificationsDepedency.init();
  ProfileDependency.init();
  HomeDependency.init();
  SearchDependency.init();

  // Language
  getIt.registerLazySingleton<LanguageRepository>(
    () => LanguageRepositoryImpl(getIt<HiveLocalStorage>()),
  );
  getIt.registerFactory(() => LanguageBloc(getIt<LanguageRepository>()));

  // Theme
  getIt.registerLazySingleton<ThemeRepository>(
    () => ThemeRepositoryImpl(getIt<HiveLocalStorage>()),
  );
  getIt.registerFactory(() => ThemeBloc(getIt<ThemeRepository>()));

  getIt.registerLazySingleton(() => ApiHelper(getIt<Dio>()));

  getIt.registerLazySingleton(
    () => Dio()..interceptors.add(getIt<ApiInterceptor>()),
  );

  getIt.registerLazySingleton(
    () => ApiInterceptor(getIt<SecureLocalStorage>()),
  );

  getIt.registerLazySingleton(
    () => SecureLocalStorage(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton(
    () => RealtimeSocketService(getIt<SecureLocalStorage>()),
  );

  getIt.registerLazySingleton(() => HiveLocalStorage());

  getIt.registerLazySingleton(
    () => NetworkInfo(getIt<InternetConnectionChecker>()),
  );

  getIt.registerLazySingleton(
    () => InternetConnectionChecker.createInstance(
      addresses: [AddressCheckOption(uri: Uri.parse(EnvConfig.socketBaseUrl))],
    ),
  );

  getIt.registerLazySingleton(() => const FlutterSecureStorage());
}
