import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n.dart';

class HomeSearchInput extends StatelessWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const HomeSearchInput({
    super.key,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHint = hintText ?? context.l10n.searchHint;
    return SizedBox(
      height: 35,
      child: TextField(
        onChanged: onChanged,
        onSubmitted: (_) => onSubmitted?.call(),
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: effectiveHint,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: IconButton(
            onPressed: onSubmitted,
            icon: const Icon(Icons.tune, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          filled: true,
          fillColor: const Color(0xFFF3F6FA),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
