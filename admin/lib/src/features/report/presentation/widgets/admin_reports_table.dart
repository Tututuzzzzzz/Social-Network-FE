import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../widgets/admin_display_formatters.dart';
import '../../../../widgets/admin_empty_state.dart';
import '../../../../widgets/admin_status_pill.dart';
import '../../../../widgets/admin_table_shell.dart';
import '../../../admin/presentation/bloc/dashboard/admin_dashboard_cubit.dart';
import '../../domain/entities/admin_report.dart';
import 'admin_report_detail_dialog.dart';

class AdminReportsTable extends StatelessWidget {
  final List<AdminReport> reports;
  final String? busyReportId;

  const AdminReportsTable({
    super.key,
    required this.reports,
    this.busyReportId,
  });

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const AdminEmptyState(
        icon: Icons.flag_outlined,
        title: 'Không có báo cáo nào',
        message: 'Không có báo cáo nào để hiển thị. Hãy kiểm tra lại sau nhé!',
      );
    }

    return AdminTableShell(
      title: 'Báo cáo',
      subtitle: 'Xem nội dung đã được báo cáo',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: Theme.of(context).textTheme.labelLarge,
          columns: const [
            DataColumn(label: Text('Mục tiêu')),
            DataColumn(label: Text('Lý do')),
            DataColumn(label: Text('Báo cáo bởi')),
            DataColumn(label: Text('Trạng thái')),
            DataColumn(label: Text('Được tạo')),
            DataColumn(label: Text('Hành động')),
          ],
          rows: reports.map((report) {
            final busy = busyReportId == report.id;
            return DataRow(
              onSelectChanged: (_) =>
                  showAdminReportDetailDialog(context: context, report: report),
              cells: [
                DataCell(
                  Text('${report.targetType} ${shortId(report.targetId)}'),
                ),
                DataCell(Text(report.reason)),
                DataCell(Text(report.reporterName)),
                DataCell(
                  AdminStatusPill(
                    label: report.status,
                    color: report.isOpen
                        ? const Color(0xFFB42318)
                        : const Color(0xFF0F766E),
                  ),
                ),
                DataCell(Text(formatAdminDate(report.createdAt))),
                DataCell(
                  IconButton(
                    tooltip: 'Giải quyết báo cáo',
                    onPressed: busy
                        ? null
                        : () => context
                              .read<AdminDashboardCubit>()
                              .resolveReport(report.id),
                    icon: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
