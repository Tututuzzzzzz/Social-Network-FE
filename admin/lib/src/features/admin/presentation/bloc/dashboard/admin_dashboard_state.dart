import 'package:equatable/equatable.dart';

import '../../../domain/entities/admin_dashboard_snapshot.dart';

enum AdminDashboardStatus { initial, loading, ready, failure }

enum AdminSection { overview, users, posts, reports }

class AdminDashboardState extends Equatable {
  final AdminDashboardStatus status;
  final AdminSection section;
  final AdminDashboardSnapshot snapshot;
  final String? message;
  final String? busyPostId;
  final String? busyReportId;
  final Set<String> hiddenPostIds;

  const AdminDashboardState({
    required this.status,
    required this.section,
    required this.snapshot,
    this.message,
    this.busyPostId,
    this.busyReportId,
    this.hiddenPostIds = const {},
  });

  const AdminDashboardState.initial()
    : this(
        status: AdminDashboardStatus.initial,
        section: AdminSection.overview,
        snapshot: AdminDashboardSnapshot.empty,
      );

  AdminDashboardState copyWith({
    AdminDashboardStatus? status,
    AdminSection? section,
    AdminDashboardSnapshot? snapshot,
    String? message,
    String? busyPostId,
    String? busyReportId,
    Set<String>? hiddenPostIds,
    bool clearMessage = false,
    bool clearBusyPost = false,
    bool clearBusyReport = false,
  }) {
    return AdminDashboardState(
      status: status ?? this.status,
      section: section ?? this.section,
      snapshot: snapshot ?? this.snapshot,
      message: clearMessage ? null : message ?? this.message,
      busyPostId: clearBusyPost ? null : busyPostId ?? this.busyPostId,
      busyReportId: clearBusyReport ? null : busyReportId ?? this.busyReportId,
      hiddenPostIds: hiddenPostIds ?? this.hiddenPostIds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    section,
    snapshot,
    message,
    busyPostId,
    busyReportId,
    hiddenPostIds,
  ];
}
