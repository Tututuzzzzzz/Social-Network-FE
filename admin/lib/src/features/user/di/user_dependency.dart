import '../../../configs/injector/injector.dart';
import '../data/datasources/admin_user_remote_datasource.dart';
import '../data/repositories/admin_user_repository_impl.dart';
import '../domain/repositories/admin_user_repository.dart';
import '../domain/usecases/get_admin_user_detail_usecase.dart';
import '../domain/usecases/get_admin_users_usecase.dart';
import '../presentation/bloc/detail/admin_user_detail_cubit.dart';

void initUserDependency() {
  injector
    ..registerLazySingleton<AdminUserRemoteDataSource>(
      () => AdminUserRemoteDataSourceImpl(injector()),
    )
    ..registerLazySingleton<AdminUserRepository>(
      () => AdminUserRepositoryImpl(injector()),
    )
    ..registerLazySingleton<GetAdminUsersUseCase>(
      () => GetAdminUsersUseCase(injector()),
    )
    ..registerLazySingleton<GetAdminUserDetailUseCase>(
      () => GetAdminUserDetailUseCase(injector()),
    )
    ..registerFactory<AdminUserDetailCubit>(
      () => AdminUserDetailCubit(injector()),
    );
}
