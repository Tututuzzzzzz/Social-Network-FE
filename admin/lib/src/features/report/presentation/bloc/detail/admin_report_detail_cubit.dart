import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../post/domain/entities/admin_post_detail.dart';
import '../../../../post/domain/usecases/get_admin_post_detail_usecase.dart';
import '../../../domain/entities/admin_report.dart';
import '../../../domain/usecases/get_admin_reports_by_post_usecase.dart';
import '../../../domain/usecases/resolve_admin_report_usecase.dart';
import 'admin_report_detail_state.dart';

class AdminReportDetailCubit extends Cubit<AdminReportDetailState> {
  final GetAdminReportsByPostUseCase _getReportsByPost;
  final GetAdminPostDetailUseCase _getPostDetail;
  final ResolveAdminReportUseCase _reviewReport;
  String? _currentPostId;

  AdminReportDetailCubit(
    this._getReportsByPost,
    this._getPostDetail,
    this._reviewReport,
  )
    : super(const AdminReportDetailState.initial());

  Future<void> load(String postId) async {
    _currentPostId = postId;
    emit(
      state.copyWith(
        status: AdminReportDetailStatus.loading,
        clearMessage: true,
        clearPostMessage: true,
      ),
    );

    try {
      final reports = await _getReportsByPost(postId);

      final postDetailResult = await _loadPostDetail(postId);
      emit(
        state.copyWith(
          status: AdminReportDetailStatus.ready,
          reports: reports,
          postDetail: postDetailResult.detail,
          postMessage: postDetailResult.message,
          clearMessage: true,
          clearPostMessage: postDetailResult.message == null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AdminReportDetailStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> reviewReport(String reportId, String status) async {
    emit(
      state.copyWith(
        busyReportId: reportId,
        clearMessage: true,
      ),
    );

    try {
      await _reviewReport(reportId, status: status);
      final postId = _currentPostId;
      final reports = postId == null
          ? _replaceReportStatus(reportId, status)
          : await _getReportsByPost(postId);
      emit(
        state.copyWith(
          reports: reports,
          clearBusyReport: true,
          clearMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          message: error.toString(),
          clearBusyReport: true,
        ),
      );
    }
  }

  List<AdminReport> _replaceReportStatus(String reportId, String status) {
    return state.reports
        .map(
          (report) => report.id == reportId
              ? AdminReport(
                  id: report.id,
                  targetId: report.targetId,
                  targetType: report.targetType,
                  reason: report.reason,
                  reporterName: report.reporterName,
                  status: status,
                  createdAt: report.createdAt,
                  targetAuthorName: report.targetAuthorName,
                  targetAuthorUsername: report.targetAuthorUsername,
                  targetAuthorAvatarUrl: report.targetAuthorAvatarUrl,
                  targetContent: report.targetContent,
                  targetMediaUrls: report.targetMediaUrls,
                )
              : report,
        )
        .toList();
  }

  Future<_PostDetailResult> _loadPostDetail(String postId) async {
    try {
      final detail = await _getPostDetail(postId);
      return _PostDetailResult(detail: detail);
    } catch (error) {
      return _PostDetailResult(message: error.toString());
    }
  }
}

class _PostDetailResult {
  final AdminPostDetail? detail;
  final String? message;

  const _PostDetailResult({this.detail, this.message});
}
