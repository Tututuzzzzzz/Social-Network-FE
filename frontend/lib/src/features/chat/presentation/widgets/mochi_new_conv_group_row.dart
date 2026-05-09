import 'package:flutter/material.dart';

import 'mochi_dm_styles.dart';

/// Section "Tao nhom chat" với nút tạo nhóm bên phải (hoặc bên dưới nếu màn hẹp).
class MochiNewConvGroupRow extends StatelessWidget {
  const MochiNewConvGroupRow({
    super.key,
    required this.onCreateGroup,
  });

  final VoidCallback onCreateGroup;

  Widget _buildCreateGroupButton() {
    return FilledButton.icon(
      onPressed: onCreateGroup,
      icon: const Icon(Icons.group_add_outlined, size: 18),
      label: const Text('Tạo nhóm'),
      style: FilledButton.styleFrom(
        backgroundColor: MochiDmStyles.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 36),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: MochiDmStyles.divider, width: 1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 260;
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tạo nhóm chat',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: MochiDmStyles.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildCreateGroupButton(),
                ),
              ],
            );
          }

          return Row(
            children: [
              const Expanded(
                child: Text(
                  'Tạo nhóm chat',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: MochiDmStyles.primaryText,
                  ),
                ),
              ),
              _buildCreateGroupButton(),
            ],
          );
        },
      ),
    );
  }
}
