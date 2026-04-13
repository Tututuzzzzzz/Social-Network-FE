import 'package:flutter/material.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onTapAction;

  const HomeSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (actionText != null)
          TextButton(onPressed: onTapAction, child: Text(actionText!)),
      ],
    );
  }
}
