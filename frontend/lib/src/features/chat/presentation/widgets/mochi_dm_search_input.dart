import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/theme/app_colors.dart';
import 'mochi_dm_styles.dart';

class MochiDmSearchInput extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final EdgeInsetsGeometry padding;
  final Color fillColor;
  final Color hintColor;
  final Color iconColor;
  final Color focusedBorderColor;
  final double borderRadius;
  final String? hintText;
  final bool dense;

  const MochiDmSearchInput({
    super.key,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.fillColor = MochiDmStyles.searchBackground,
    this.hintColor = MochiDmStyles.searchHint,
    this.iconColor = MochiDmStyles.searchHint,
    this.focusedBorderColor = const Color(0xFFCFD3DC),
    this.borderRadius = 18,
    this.hintText,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: padding,
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText ?? context.l10n.searchLabel,
          hintStyle: TextStyle(
            color: hintColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(Icons.search, color: iconColor, size: 18),
          filled: true,
          fillColor: fillColor,
          isDense: dense,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: focusedBorderColor),
          ),
        ),
      ),
    );
  }
}
