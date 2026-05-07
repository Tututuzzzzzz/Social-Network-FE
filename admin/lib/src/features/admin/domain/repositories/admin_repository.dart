import '../entities/admin_dashboard_snapshot.dart';

abstract class AdminRepository {
  Future<AdminDashboardSnapshot> getDashboardSnapshot();
}
