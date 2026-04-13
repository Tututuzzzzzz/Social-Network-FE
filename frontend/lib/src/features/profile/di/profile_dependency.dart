import '../../../configs/injector/injector_conf.dart';
import '../../../core/api/api_helper.dart';
import '../data/datasources/profile_local_datasource.dart';
import '../data/datasources/profile_remote_datasource.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/usecases/fetch_profile_items_usecase.dart';
import '../presentation/bloc/profile/profile_bloc.dart';

class ProfileDependency {
  ProfileDependency._();

  static void init() {
    if (!getIt.isRegistered<ProfileBloc>()) {
      getIt.registerFactory(
        () => ProfileBloc(getIt<FetchProfileItemsUseCase>()),
      );
    }

    if (!getIt.isRegistered<FetchProfileItemsUseCase>()) {
      getIt.registerLazySingleton(
        () => FetchProfileItemsUseCase(getIt<ProfileRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<ProfileRepositoryImpl>()) {
      getIt.registerLazySingleton(
        () => ProfileRepositoryImpl(
          getIt<ProfileRemoteDataSourceImpl>(),
          getIt<ProfileLocalDataSourceImpl>(),
        ),
      );
    }

    if (!getIt.isRegistered<ProfileRemoteDataSourceImpl>()) {
      getIt.registerLazySingleton(
        () => ProfileRemoteDataSourceImpl(getIt<ApiHelper>()),
      );
    }

    if (!getIt.isRegistered<ProfileLocalDataSourceImpl>()) {
      getIt.registerLazySingleton(() => ProfileLocalDataSourceImpl());
    }
  }
}
