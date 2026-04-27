import '../../domain/entities/admin_dashboard_snapshot.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  const AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<AdminDashboardSnapshot> getDashboardSnapshot() {
    return _remoteDataSource.fetchDashboardSnapshot();
  }

  @override
  Future<void> deletePost(String postId) {
    return _remoteDataSource.deletePost(postId);
  }

  @override
  Future<void> resolveReport(String reportId) {
    return _remoteDataSource.resolveReport(reportId);
  }
}
