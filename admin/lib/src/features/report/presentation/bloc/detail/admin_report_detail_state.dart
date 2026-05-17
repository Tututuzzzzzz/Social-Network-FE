import 'package:equatable/equatable.dart';

import '../../../../post/domain/entities/admin_post_detail.dart';
import '../../../domain/entities/admin_report.dart';

enum AdminReportDetailStatus { initial, loading, ready, failure }

class AdminReportDetailState extends Equatable {
  final AdminReportDetailStatus status;
  final List<AdminReport> reports;
  final AdminPostDetail? postDetail;
  final String? busyReportId;
  final String? postMessage;
  final String? message;

  const AdminReportDetailState({
    required this.status,
    required this.reports,
    this.postDetail,
    this.busyReportId,
    this.postMessage,
    this.message,
  });

  const AdminReportDetailState.initial()
    : this(status: AdminReportDetailStatus.initial, reports: const []);

  AdminReportDetailState copyWith({
    AdminReportDetailStatus? status,
    List<AdminReport>? reports,
    AdminPostDetail? postDetail,
    String? busyReportId,
    String? postMessage,
    String? message,
    bool clearMessage = false,
    bool clearPostMessage = false,
    bool clearBusyReport = false,
  }) {
    return AdminReportDetailState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      postDetail: postDetail ?? this.postDetail,
      busyReportId: clearBusyReport
          ? null
          : busyReportId ?? this.busyReportId,
      postMessage: clearPostMessage
          ? null
          : postMessage ?? this.postMessage,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reports,
        postDetail,
        busyReportId,
        postMessage,
        message,
      ];
}
