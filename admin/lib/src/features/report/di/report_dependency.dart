import '../../../configs/injector/injector.dart';
import '../data/datasources/admin_report_remote_datasource.dart';
import '../data/repositories/admin_report_repository_impl.dart';
import '../domain/repositories/admin_report_repository.dart';
import '../domain/usecases/get_admin_reports_by_post_usecase.dart';
import '../domain/usecases/get_admin_reports_usecase.dart';
import '../domain/usecases/resolve_admin_report_usecase.dart';
import '../presentation/bloc/detail/admin_report_detail_cubit.dart';

void initReportDependency() {
  injector
    ..registerLazySingleton<AdminReportRemoteDataSource>(
      () => AdminReportRemoteDataSourceImpl(injector()),
    )
    ..registerLazySingleton<AdminReportRepository>(
      () => AdminReportRepositoryImpl(injector()),
    )
    ..registerLazySingleton<GetAdminReportsUseCase>(
      () => GetAdminReportsUseCase(injector()),
    )
    ..registerLazySingleton<GetAdminReportsByPostUseCase>(
      () => GetAdminReportsByPostUseCase(injector()),
    )
    ..registerLazySingleton<ResolveAdminReportUseCase>(
      () => ResolveAdminReportUseCase(injector()),
    )
    ..registerFactory<AdminReportDetailCubit>(
      () => AdminReportDetailCubit(injector(), injector(), injector()),
    );
}
