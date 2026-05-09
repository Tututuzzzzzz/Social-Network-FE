import 'package:flutter/material.dart';

import 'mochi_dm_search_input.dart';
import 'mochi_dm_styles.dart';

/// Top bar dùng cho MochiNewConversationPage.
/// Gồm: back button, tiêu đề, search input.
class MochiNewConvTopBar extends StatelessWidget {
  const MochiNewConvTopBar({
    super.key,
    required this.onSearchChanged,
  });

  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MochiDmStyles.primaryGreen,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                ),
                color: MochiDmStyles.topBarText,
              ),
              const Expanded(
                child: Text(
                  'Tạo cuộc trò chuyện mới',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: MochiDmStyles.topBarText,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          MochiDmSearchInput(
            onChanged: onSearchChanged,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            fillColor: Colors.white,
            hintColor: MochiDmStyles.searchHint,
            iconColor: MochiDmStyles.searchIcon,
            focusedBorderColor: MochiDmStyles.primaryGreenSoft,
            borderRadius: 16,
            hintText: 'Tìm bạn bè',
            dense: true,
          ),
        ],
      ),
    );
  }
}
