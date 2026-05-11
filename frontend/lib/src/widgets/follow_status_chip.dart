import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class FollowStatusChip extends StatelessWidget {
  const FollowStatusChip({
    super.key,
    required this.isFollowing,
    required this.followingText,
    required this.followText,
    this.onTap,
  });

  final bool isFollowing;
  final String followingText;
  final String followText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final backgroundColor =
      isFollowing ? colors.chipFollowingBg : colors.chipFollowBg;
    final textColor =
      isFollowing ? colors.chipFollowingText : colors.chipFollowText;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          isFollowing ? followingText : followText,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}
