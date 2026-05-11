import '../../../configs/injector/injector_conf.dart';
import '../../../core/api/api_helper.dart';
import '../../../core/cache/hive_local_storage.dart';
import '../data/datasources/search_local_datasource.dart';
import '../data/datasources/search_remote_datasource.dart';
import '../data/repositories/search_repository_impl.dart';
import '../domain/usecases/search_usecase.dart';
import '../presentation/bloc/search_bloc.dart';

class SearchDependency {
  SearchDependency._();

  static void init() {
    if (!getIt.isRegistered<SearchBloc>()) {
      getIt.registerFactory(
        () => SearchBloc(
          searchUserUseCase: getIt<SearchUserUseCase>(),
          getSearchHistoryUseCase: getIt<GetSearchHistoryUseCase>(),
          saveSearchQueryUseCase: getIt<SaveSearchQueryUseCase>(),
          clearSearchHistoryUseCase: getIt<ClearSearchHistoryUseCase>(),
        ),
      );
    }

    if (!getIt.isRegistered<SearchUserUseCase>()) {
      getIt.registerLazySingleton(
        () => SearchUserUseCase(getIt<SearchRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<GetSearchHistoryUseCase>()) {
      getIt.registerLazySingleton(
        () => GetSearchHistoryUseCase(getIt<SearchRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<SaveSearchQueryUseCase>()) {
      getIt.registerLazySingleton(
        () => SaveSearchQueryUseCase(getIt<SearchRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<ClearSearchHistoryUseCase>()) {
      getIt.registerLazySingleton(
        () => ClearSearchHistoryUseCase(getIt<SearchRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<SearchRepositoryImpl>()) {
      getIt.registerLazySingleton(
        () => SearchRepositoryImpl(
          remoteDataSource: getIt<SearchRemoteDataSourceImpl>(),
          localDataSource: getIt<SearchLocalDataSourceImpl>(),
        ),
      );
    }

    if (!getIt.isRegistered<SearchRemoteDataSourceImpl>()) {
      getIt.registerLazySingleton(
        () => SearchRemoteDataSourceImpl(getIt<ApiHelper>()),
      );
    }

    if (!getIt.isRegistered<SearchLocalDataSourceImpl>()) {
      getIt.registerLazySingleton(
        () => SearchLocalDataSourceImpl(getIt<HiveLocalStorage>()),
      );
    }
  }
}
