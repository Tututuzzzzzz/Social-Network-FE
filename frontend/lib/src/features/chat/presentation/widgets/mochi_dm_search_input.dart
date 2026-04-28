import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n.dart';
import 'mochi_dm_styles.dart';

class MochiDmSearchInput extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const MochiDmSearchInput({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: context.l10n.searchLabel,
          hintStyle: const TextStyle(
            color: MochiDmStyles.searchHint,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search, color: MochiDmStyles.searchHint),
          filled: true,
          fillColor: MochiDmStyles.searchBackground,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFCFD3DC)),
          ),
        ),
      ),
    );
  }
}
