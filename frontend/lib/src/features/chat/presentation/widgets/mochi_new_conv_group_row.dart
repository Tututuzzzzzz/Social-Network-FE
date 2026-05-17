import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/theme/app_colors.dart';


/// Section "Tao nhom chat" với nút tạo nhóm bên phải (hoặc bên dưới nếu màn hẹp).
class MochiNewConvGroupRow extends StatelessWidget {
  const MochiNewConvGroupRow({
    super.key,
    required this.onCreateGroup,
  });

  final VoidCallback onCreateGroup;

  Widget _buildCreateGroupButton(BuildContext context) {
    final colors = AppColors.of(context);

    return FilledButton.icon(
      onPressed: onCreateGroup,
      icon: const Icon(Icons.group_add_outlined, size: 18),
      label: Text(context.l10n.createGroupChatAction),
      style: FilledButton.styleFrom(
        backgroundColor: colors.accent,
        foregroundColor: colors.appBarForeground,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 36),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.subtleBorder, width: 1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 260;
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.createGroupChatTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildCreateGroupButton(context),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.createGroupChatTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              _buildCreateGroupButton(context),
            ],
          );
        },
      ),
    );
  }
}
