import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../widgets/admin_display_formatters.dart';
import '../../../../widgets/admin_empty_state.dart';
import '../../../../widgets/admin_status_pill.dart';
import '../../../../widgets/admin_table_shell.dart';
import '../../../admin/presentation/bloc/dashboard/admin_dashboard_cubit.dart';
import '../../../post/domain/entities/admin_post.dart';
import '../../../user/domain/entities/admin_user.dart';
import '../../domain/entities/admin_report.dart';
import 'admin_report_detail_dialog.dart';

class AdminReportsTable extends StatelessWidget {
  final List<AdminReport> reports;
  final List<AdminPost> posts;
  final List<AdminUser> users;
  final Set<String> hiddenPostIds;
  final String? busyReportId;

  const AdminReportsTable({
    super.key,
    required this.reports,
    this.posts = const [],
    this.users = const [],
    this.hiddenPostIds = const {},
    this.busyReportId,
  });

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const AdminEmptyState(
        icon: Icons.flag_outlined,
        title: 'Không có báo cáo nào',
        message:
            'Không có báo cáo nào để hiển thị. Hãy kiểm tra lại sau nhé!',
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
            final busy = busyReportId == report.targetId;
            final hidden = hiddenPostIds.contains(report.targetId);
            final post = _findPost(report.targetId);
            return DataRow(
              onSelectChanged: (_) {
                showAdminReportDetailDialog(
                  context: context,
                  report: report,
                  initialPost: post,
                );
              },
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
                    tooltip: hidden
                        ? 'Khôi phục bài viết'
                        : 'Ẩn bài viết và giải quyết báo cáo liên quan',
                    onPressed: busy
                        ? null
                        : () {
                            final cubit = context.read<AdminDashboardCubit>();
                            if (hidden) {
                              cubit.restorePost(report.targetId);
                            } else {
                              cubit.hidePost(report.targetId);
                            }
                          },
                    icon: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            hidden
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  AdminPost? _findPost(String postId) {
    for (final post in posts) {
      if (post.id == postId) {
        return _resolvePostAuthor(post);
      }
    }
    return null;
  }

  AdminPost _resolvePostAuthor(AdminPost post) {
    final authorLooksMissing =
        post.authorUsername.trim().isEmpty ||
        post.authorUsername.trim().toLowerCase() == 'unknown' ||
        post.authorDisplayName.trim().isEmpty ||
        post.authorDisplayName.trim().toLowerCase() == 'unknown';
    if (!authorLooksMissing) {
      return post;
    }

    for (final user in users) {
      if (user.id == post.authorId) {
        return AdminPost(
          id: post.id,
          authorId: post.authorId,
          authorUsername: user.username,
          authorDisplayName: user.displayName,
          authorAvatarUrl: user.avatarUrl ?? post.authorAvatarUrl,
          content: post.content,
          likesCount: post.likesCount,
          commentsCount: post.commentsCount,
          likeIds: post.likeIds,
          media: post.media,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
        );
      }
    }

    return post;
  }
}
