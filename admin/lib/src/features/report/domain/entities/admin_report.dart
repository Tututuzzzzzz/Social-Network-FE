import 'package:equatable/equatable.dart';

class AdminReport extends Equatable {
  final String id;
  final String targetId;
  final String targetType;
  final String reason;
  final String reporterName;
  final String status;
  final DateTime createdAt;
  final String? targetAuthorName;
  final String? targetAuthorUsername;
  final String? targetAuthorAvatarUrl;
  final String? targetContent;
  final List<String> targetMediaUrls;

  const AdminReport({
    required this.id,
    required this.targetId,
    required this.targetType,
    required this.reason,
    required this.reporterName,
    required this.status,
    required this.createdAt,
    this.targetAuthorName,
    this.targetAuthorUsername,
    this.targetAuthorAvatarUrl,
    this.targetContent,
    this.targetMediaUrls = const [],
  });

  bool get isOpen {
    final normalizedStatus = status.toLowerCase();
    return normalizedStatus == 'open' || normalizedStatus == 'pending';
  }

  @override
  List<Object?> get props => [
    id,
    targetId,
    targetType,
    reason,
    reporterName,
    status,
    createdAt,
    targetAuthorName,
    targetAuthorUsername,
    targetAuthorAvatarUrl,
    targetContent,
    targetMediaUrls,
  ];
}
