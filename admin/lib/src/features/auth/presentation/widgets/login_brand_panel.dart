import 'package:flutter/material.dart';

class LoginBrandPanel extends StatelessWidget {
  final bool compact;

  const LoginBrandPanel({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: compact ? 190 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!compact)
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shield, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  'Mochi Admin',
                  style: textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF17211D),
                  ),
                ),
              ],
            ),
          if (!compact) const SizedBox(height: 42),
          Text(
            'Chào mừng tới trang quản trị',
            style: textTheme.displaySmall?.copyWith(
              color: const Color(0xFF17211D),
            ),
          ),
        ],
      ),
    );
  }
}
