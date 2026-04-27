import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/delete_admin_post_usecase.dart';
import '../../../domain/usecases/get_admin_dashboard_usecase.dart';
import '../../../domain/usecases/resolve_admin_report_usecase.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final GetAdminDashboardUseCase _getDashboard;
  final DeleteAdminPostUseCase _deletePost;
  final ResolveAdminReportUseCase _resolveReport;

  AdminDashboardCubit(this._getDashboard, this._deletePost, this._resolveReport)
    : super(const AdminDashboardState.initial());

  Future<void> load() async {
    emit(
      state.copyWith(status: AdminDashboardStatus.loading, clearMessage: true),
    );

    try {
      final snapshot = await _getDashboard();
      emit(
        state.copyWith(
          status: AdminDashboardStatus.ready,
          snapshot: snapshot,
          clearBusyPost: true,
          clearBusyReport: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AdminDashboardStatus.failure,
          message: error.toString(),
          clearBusyPost: true,
          clearBusyReport: true,
        ),
      );
    }
  }

  void selectSection(AdminSection section) {
    emit(state.copyWith(section: section, clearMessage: true));
  }

  Future<void> removePost(String postId) async {
    emit(state.copyWith(busyPostId: postId, clearMessage: true));

    try {
      await _deletePost(postId);
      await load();
    } catch (error) {
      emit(state.copyWith(message: error.toString(), clearBusyPost: true));
    }
  }

  Future<void> resolveReport(String reportId) async {
    emit(state.copyWith(busyReportId: reportId, clearMessage: true));

    try {
      await _resolveReport(reportId);
      await load();
    } catch (error) {
      emit(state.copyWith(message: error.toString(), clearBusyReport: true));
    }
  }
}
