import '../../../configs/injector/injector_conf.dart';
import '../../../core/api/api_helper.dart';
import '../data/datasources/reels_local_datasource.dart';
import '../data/datasources/reels_remote_datasource.dart';
import '../data/repositories/reels_repository_impl.dart';
import '../domain/usecases/fetch_reels_items_usecase.dart';
import '../presentation/bloc/reels/reels_bloc.dart';

class ReelsDependency {
  ReelsDependency._();

  static void init() {
    if (!getIt.isRegistered<ReelsBloc>()) {
      getIt.registerFactory(() => ReelsBloc(getIt<FetchReelsItemsUseCase>()));
    }

    if (!getIt.isRegistered<FetchReelsItemsUseCase>()) {
      getIt.registerLazySingleton(
        () => FetchReelsItemsUseCase(getIt<ReelsRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<ReelsRepositoryImpl>()) {
      getIt.registerLazySingleton(
        () => ReelsRepositoryImpl(
          getIt<ReelsRemoteDataSourceImpl>(),
          getIt<ReelsLocalDataSourceImpl>(),
        ),
      );
    }

    if (!getIt.isRegistered<ReelsRemoteDataSourceImpl>()) {
      getIt.registerLazySingleton(
        () => ReelsRemoteDataSourceImpl(getIt<ApiHelper>()),
      );
    }

    if (!getIt.isRegistered<ReelsLocalDataSourceImpl>()) {
      getIt.registerLazySingleton(() => ReelsLocalDataSourceImpl());
    }
  }
}
