import '../../domain/entities/admin_report.dart';

class AdminReportModel extends AdminReport {
  const AdminReportModel({
    required super.id,
    required super.targetId,
    required super.targetType,
    required super.reason,
    required super.reporterName,
    required super.status,
    required super.createdAt,
  });

  factory AdminReportModel.fromJson(Map<String, dynamic> json) {
    return AdminReportModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      targetId: (json['targetId'] ?? json['postId'] ?? '').toString(),
      targetType: (json['targetType'] ?? 'post').toString(),
      reason: (json['reason'] ?? '').toString(),
      reporterName: (json['reporterName'] ?? json['reporterId'] ?? 'unknown')
          .toString(),
      status: (json['status'] ?? 'open').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
