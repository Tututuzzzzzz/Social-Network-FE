import '../../../configs/injector/injector.dart';
import '../data/repositories/admin_repository_impl.dart';
import '../domain/repositories/admin_repository.dart';
import '../domain/usecases/get_admin_dashboard_usecase.dart';
import '../presentation/bloc/dashboard/admin_dashboard_cubit.dart';

void initAdminDependency() {
  injector
    ..registerLazySingleton<AdminRepository>(
      () => AdminRepositoryImpl(injector(), injector(), injector()),
    )
    ..registerLazySingleton<GetAdminDashboardUseCase>(
      () => GetAdminDashboardUseCase(injector()),
    )
    ..registerFactory<AdminDashboardCubit>(
      () => AdminDashboardCubit(injector(), injector(), injector()),
    );
}
