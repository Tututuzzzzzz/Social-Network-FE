import '../../../configs/injector/injector_conf.dart';
import '../../../core/api/api_helper.dart';
import '../data/datasources/home_local_datasource.dart';
import '../data/datasources/home_remote_datasource.dart';
import '../data/repositories/home_repository_impl.dart';
import '../domain/usecases/fetch_home_items_usecase.dart';
import '../presentation/bloc/home/home_bloc.dart';

class HomeDependency {
  HomeDependency._();

  static void init() {
    if (!getIt.isRegistered<HomeBloc>()) {
      getIt.registerFactory(() => HomeBloc(getIt<FetchHomeItemsUseCase>()));
    }

    if (!getIt.isRegistered<FetchHomeItemsUseCase>()) {
      getIt.registerLazySingleton(
        () => FetchHomeItemsUseCase(getIt<HomeRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<HomeRepositoryImpl>()) {
      getIt.registerLazySingleton(
        () => HomeRepositoryImpl(
          getIt<HomeRemoteDataSourceImpl>(),
          getIt<HomeLocalDataSourceImpl>(),
        ),
      );
    }

    if (!getIt.isRegistered<HomeRemoteDataSourceImpl>()) {
      getIt.registerLazySingleton(
        () => HomeRemoteDataSourceImpl(getIt<ApiHelper>()),
      );
    }

    if (!getIt.isRegistered<HomeLocalDataSourceImpl>()) {
      getIt.registerLazySingleton(() => HomeLocalDataSourceImpl());
    }
  }
}
