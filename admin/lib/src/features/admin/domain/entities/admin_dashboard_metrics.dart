import 'package:equatable/equatable.dart';

class AdminDashboardMetrics extends Equatable {
  final int usersCount;
  final int postsCount;
  final int reportsCount;
  final int openReportsCount;

  const AdminDashboardMetrics({
    required this.usersCount,
    required this.postsCount,
    required this.reportsCount,
    required this.openReportsCount,
  });

  @override
  List<Object?> get props => [
    usersCount,
    postsCount,
    reportsCount,
    openReportsCount,
  ];
}
