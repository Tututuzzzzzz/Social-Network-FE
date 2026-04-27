import '../../../configs/injector/injector.dart';
import '../data/datasources/admin_auth_remote_datasource.dart';
import '../data/repositories/admin_auth_repository_impl.dart';
import '../domain/repositories/admin_auth_repository.dart';
import '../domain/usecases/login_admin_usecase.dart';
import '../domain/usecases/logout_admin_usecase.dart';
import '../domain/usecases/restore_admin_session_usecase.dart';
import '../presentation/bloc/auth/admin_auth_cubit.dart';

void initAuthDependency() {
  injector
    ..registerLazySingleton<AdminAuthRemoteDataSource>(
      () => AdminAuthRemoteDataSourceImpl(injector(), injector()),
    )
    ..registerLazySingleton<AdminAuthRepository>(
      () => AdminAuthRepositoryImpl(injector()),
    )
    ..registerLazySingleton<LoginAdminUseCase>(
      () => LoginAdminUseCase(injector()),
    )
    ..registerLazySingleton<LogoutAdminUseCase>(
      () => LogoutAdminUseCase(injector()),
    )
    ..registerLazySingleton<RestoreAdminSessionUseCase>(
      () => RestoreAdminSessionUseCase(injector()),
    )
    ..registerFactory<AdminAuthCubit>(
      () => AdminAuthCubit(injector(), injector(), injector()),
    );
}
