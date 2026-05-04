import 'package:equatable/equatable.dart';

class AdminReport extends Equatable {
  final String id;
  final String targetId;
  final String targetType;
  final String reason;
  final String reporterName;
  final String status;
  final DateTime createdAt;

  const AdminReport({
    required this.id,
    required this.targetId,
    required this.targetType,
    required this.reason,
    required this.reporterName,
    required this.status,
    required this.createdAt,
  });

  bool get isOpen => status.toLowerCase() == 'open';

  @override
  List<Object?> get props => [
    id,
    targetId,
    targetType,
    reason,
    reporterName,
    status,
    createdAt,
  ];
}
