import '../../../configs/injector/injector.dart';
import '../data/datasources/admin_remote_datasource.dart';
import '../data/repositories/admin_repository_impl.dart';
import '../domain/repositories/admin_repository.dart';
import '../domain/usecases/delete_admin_post_usecase.dart';
import '../domain/usecases/get_admin_dashboard_usecase.dart';
import '../domain/usecases/resolve_admin_report_usecase.dart';
import '../presentation/bloc/dashboard/admin_dashboard_cubit.dart';

void initAdminDependency() {
  injector
    ..registerLazySingleton<AdminRemoteDataSource>(
      () => AdminRemoteDataSourceImpl(injector()),
    )
    ..registerLazySingleton<AdminRepository>(
      () => AdminRepositoryImpl(injector()),
    )
    ..registerLazySingleton<GetAdminDashboardUseCase>(
      () => GetAdminDashboardUseCase(injector()),
    )
    ..registerLazySingleton<DeleteAdminPostUseCase>(
      () => DeleteAdminPostUseCase(injector()),
    )
    ..registerLazySingleton<ResolveAdminReportUseCase>(
      () => ResolveAdminReportUseCase(injector()),
    )
    ..registerFactory<AdminDashboardCubit>(
      () => AdminDashboardCubit(injector(), injector(), injector()),
    );
}
