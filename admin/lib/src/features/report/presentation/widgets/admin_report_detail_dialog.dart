import 'package:flutter/material.dart';

import '../../../../widgets/admin_display_formatters.dart';
import '../../../../widgets/admin_status_pill.dart';
import '../../domain/entities/admin_report.dart';

Future<void> showAdminReportDetailDialog({
  required BuildContext context,
  required AdminReport report,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Chi tiet bao cao',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Dong',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AdminStatusPill(
                  label: report.status,
                  color: report.isOpen
                      ? const Color(0xFFB42318)
                      : const Color(0xFF0F766E),
                ),
                const SizedBox(height: 18),
                _ReportLine(label: 'Report ID', value: report.id),
                _ReportLine(label: 'Target', value: report.targetType),
                _ReportLine(label: 'Target ID', value: report.targetId),
                _ReportLine(label: 'Reason', value: report.reason),
                _ReportLine(label: 'Reporter', value: report.reporterName),
                _ReportLine(
                  label: 'Created',
                  value: formatAdminDate(report.createdAt),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _ReportLine extends StatelessWidget {
  final String label;
  final String value;

  const _ReportLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 3),
          SelectableText(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
