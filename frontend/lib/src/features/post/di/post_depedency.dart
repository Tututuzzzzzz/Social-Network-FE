import '../../../configs/injector/injector_conf.dart';
import '../../../core/cache/hive_local_storage.dart';
import '../../../core/api/api_helper.dart';
import '../../../core/network/network_checker.dart';
import '../data/datasources/post_local_datasource.dart';
import '../data/datasources/post_remote_datasource.dart';
import '../data/repositories/post_repository_impl.dart';
import '../domain/repositories/post_repository.dart';
import '../domain/usecases/create_post_usecase.dart';
import '../domain/usecases/create_comment_usecase.dart';
import '../domain/usecases/delete_post_usecase.dart';
import '../domain/usecases/get_comments_usecase.dart';
import '../domain/usecases/get_post_usecase.dart';
import '../domain/usecases/toggle_like_post_usecase.dart';
import '../domain/usecases/update_post_usecase.dart';
import '../presentation/bloc/post/post_bloc.dart';
import '../presentation/bloc/post_form/post_form_bloc.dart';

class PostDepedency {
  PostDepedency._();

  static void init() {
    getIt.registerFactory(
      () => PostBloc(
        getIt<CreatePostUseCase>(),
        getIt<DeletePostUseCase>(),
        getIt<GetPostUseCase>(),
        getIt<UpdatePostUseCase>(),
        getIt<ToggleLikePostUseCase>(),
      ),
    );

    getIt.registerFactory(() => PostFormBloc());

    getIt.registerLazySingleton<PostRemoteDatasource>(
      () => PostRemoteDatasourceImpl(getIt<ApiHelper>()),
    );

    getIt.registerLazySingleton<PostLocalDatasource>(
      () => PostLocalDatasourceImpl(getIt<HiveLocalStorage>()),
    );

    getIt.registerLazySingleton<PostRepository>(
      () => PostRepositoryImpl(
        getIt<PostRemoteDatasource>(),
        getIt<PostLocalDatasource>(),
        getIt<NetworkInfo>(),
        getIt<HiveLocalStorage>(),
      ),
    );

    getIt.registerLazySingleton(() => GetPostUseCase(getIt<PostRepository>()));

    getIt.registerLazySingleton(
      () => CreatePostUseCase(getIt<PostRepository>()),
    );

    getIt.registerLazySingleton(
      () => UpdatePostUseCase(getIt<PostRepository>()),
    );

    getIt.registerLazySingleton(
      () => DeletePostUseCase(getIt<PostRepository>()),
    );

    getIt.registerLazySingleton(
      () => ToggleLikePostUseCase(getIt<PostRepository>()),
    );

    getIt.registerLazySingleton(
      () => CreateCommentUseCase(getIt<PostRepository>()),
    );

    getIt.registerLazySingleton(
      () => GetCommentsUseCase(getIt<PostRepository>()),
    );
  }
}
