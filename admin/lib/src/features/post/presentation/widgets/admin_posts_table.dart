import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../widgets/admin_empty_state.dart';
import '../../../../widgets/admin_display_formatters.dart';
import '../../../../widgets/admin_table_shell.dart';
import '../../../admin/presentation/bloc/dashboard/admin_dashboard_cubit.dart';
import '../../domain/entities/admin_post.dart';
import 'admin_post_detail_sheet.dart';
import 'admin_post_summary.dart';
import 'delete_post_dialog.dart';

class AdminPostsTable extends StatelessWidget {
  final List<AdminPost> posts;
  final String? busyPostId;

  const AdminPostsTable({super.key, required this.posts, this.busyPostId});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const AdminEmptyState(
        icon: Icons.article_outlined,
        title: 'Không có bài viết nào',
        message: 'Không có bài viết nào để hiển thị. Hãy kiểm tra lại sau nhé!',
      );
    }

    return AdminTableShell(
      title: 'Bài viết gần đây',
      subtitle: 'Danh sách các bài viết mới nhất.',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: Theme.of(context).textTheme.labelLarge,
          columnSpacing: 28,
          columns: const [
            DataColumn(label: Text('Post')),
            DataColumn(label: Text('Author')),
            DataColumn(label: Text('Engagement')),
            DataColumn(label: Text('Created')),
            DataColumn(label: Text('Action')),
          ],
          rows: posts.map((post) {
            final busy = busyPostId == post.id;
            return DataRow(
              onSelectChanged: (_) =>
                  showAdminPostDetailSheet(context: context, post: post),
              cells: [
                DataCell(AdminPostSummary(post: post)),
                DataCell(Text(post.authorUsername)),
                DataCell(
                  Text(
                    '${post.likesCount} likes - ${post.commentsCount} comments',
                  ),
                ),
                DataCell(Text(formatAdminDate(post.createdAt))),
                DataCell(
                  IconButton(
                    tooltip: 'Delete post',
                    onPressed: busy
                        ? null
                        : () => _confirmDelete(context, post),
                    icon: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AdminPost post) async {
    final confirmed = await showDeletePostDialog(context: context, post: post);
    if (confirmed && context.mounted) {
      context.read<AdminDashboardCubit>().removePost(post.id);
    }
  }
}
