import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.textColor,
    this.borderRadius = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final resolvedColor = color ?? colors.accent;
    final resolvedTextColor = textColor ?? colors.appBarForeground;

    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: resolvedColor,
          foregroundColor: resolvedTextColor,
          minimumSize: const Size(double.infinity, 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
