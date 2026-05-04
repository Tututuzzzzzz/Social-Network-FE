import '../../../configs/injector/injector.dart';
import '../data/datasources/admin_post_remote_datasource.dart';
import '../data/repositories/admin_post_repository_impl.dart';
import '../domain/repositories/admin_post_repository.dart';
import '../domain/usecases/delete_admin_post_usecase.dart';
import '../domain/usecases/get_admin_post_detail_usecase.dart';
import '../domain/usecases/get_admin_posts_usecase.dart';
import '../presentation/bloc/detail/admin_post_detail_cubit.dart';

void initPostDependency() {
  injector
    ..registerLazySingleton<AdminPostRemoteDataSource>(
      () => AdminPostRemoteDataSourceImpl(injector()),
    )
    ..registerLazySingleton<AdminPostRepository>(
      () => AdminPostRepositoryImpl(injector()),
    )
    ..registerLazySingleton<GetAdminPostsUseCase>(
      () => GetAdminPostsUseCase(injector()),
    )
    ..registerLazySingleton<GetAdminPostDetailUseCase>(
      () => GetAdminPostDetailUseCase(injector()),
    )
    ..registerLazySingleton<DeleteAdminPostUseCase>(
      () => DeleteAdminPostUseCase(injector()),
    )
    ..registerFactory<AdminPostDetailCubit>(
      () => AdminPostDetailCubit(injector()),
    );
}
