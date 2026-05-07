import '../../../configs/injector/injector.dart';
import '../data/datasources/admin_report_remote_datasource.dart';
import '../data/repositories/admin_report_repository_impl.dart';
import '../domain/repositories/admin_report_repository.dart';
import '../domain/usecases/get_admin_reports_usecase.dart';
import '../domain/usecases/resolve_admin_report_usecase.dart';

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
    ..registerLazySingleton<ResolveAdminReportUseCase>(
      () => ResolveAdminReportUseCase(injector()),
    );
}
