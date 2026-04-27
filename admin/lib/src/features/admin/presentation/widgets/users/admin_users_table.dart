import 'package:flutter/material.dart';

import '../../../domain/entities/admin_user.dart';
import '../admin_empty_state.dart';
import '../admin_table_shell.dart';
import '../common/admin_display_formatters.dart';
import 'admin_user_identity.dart';

class AdminUsersTable extends StatelessWidget {
  final List<AdminUser> users;

  const AdminUsersTable({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const AdminEmptyState(
        icon: Icons.people_alt_outlined,
        title: 'Không có người dùng nào',
        message: 'Không có người dùng nào để hiển thị.',
      );
    }

    return AdminTableShell(
      title: 'Người dùng',
      subtitle: 'Tác giả được thu thập từ dữ liệu feed backend',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: Theme.of(context).textTheme.labelLarge,
          columns: const [
            DataColumn(label: Text('Người dùng')),
            DataColumn(label: Text('ID Người dùng')),
            DataColumn(label: Text('Bài viết')),
            DataColumn(label: Text('Hoạt động cuối cùng')),
          ],
          rows: users.map((user) {
            return DataRow(
              cells: [
                DataCell(AdminUserIdentity(user: user)),
                DataCell(SelectableText(shortId(user.id))),
                DataCell(Text('${user.postsCount}')),
                DataCell(Text(formatAdminDate(user.lastActivityAt))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
