import 'package:flutter/material.dart';

class HomeSearchInput extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const HomeSearchInput({
    super.key,
    this.hintText = 'Search people, posts, places',
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      onSubmitted: (_) => onSubmitted?.call(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: onSubmitted,
          icon: const Icon(Icons.tune),
        ),
        filled: true,
        fillColor: const Color(0xFFF3F6FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
