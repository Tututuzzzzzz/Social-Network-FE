import 'package:flutter/material.dart';
import 'package:frontend/src/core/theme/app_colors.dart';

class AuthTheme {
  const AuthTheme._();

  static AppColors colorsOf(BuildContext context) => AppColors.of(context);

  static String logoAssetOf(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? 'assets/images/logo1.jpg' : 'assets/images/logo.jpg';
  }

  static Color actionColor(BuildContext context, bool enabled) {
    final colors = colorsOf(context);
    return enabled ? colors.authPrimaryAction : colors.authDisabledAction;
  }

  static TextStyle titleStyle(BuildContext context) {
    final colors = colorsOf(context);
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: colors.authTitle,
    );
  }

  static TextStyle bodyStyle(BuildContext context) {
    final colors = colorsOf(context);
    return TextStyle(
      fontSize: 14,
      color: colors.authBody,
    );
  }

  static TextStyle linkStyle(BuildContext context) {
    final colors = colorsOf(context);
    return TextStyle(
      color: colors.authLink,
      fontWeight: FontWeight.w600,
    );
  }

  static InputDecoration inputDecoration(
    BuildContext context,
    String hint, {
    double radius = 30,
    Widget? suffixIcon,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  }) {
    final colors = colorsOf(context);

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colors.authInputHint),
      filled: true,
      fillColor: colors.authInputFill,
      contentPadding: contentPadding,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(
          color: colors.authInputBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(
          color: colors.authInputBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(
          color: colors.authPrimaryAction,
          width: 1.4,
        ),
      ),
    );
  }

  static IconButton backButton(
    BuildContext context, {
    required VoidCallback onPressed,
  }) {
    final colors = colorsOf(context);

    return IconButton(
      icon: Icon(
        Icons.chevron_left,
        color: colors.authIcon,
        size: 32,
      ),
      onPressed: onPressed,
    );
  }
}
