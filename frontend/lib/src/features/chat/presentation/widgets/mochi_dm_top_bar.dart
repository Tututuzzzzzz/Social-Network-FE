import 'package:flutter/material.dart';

import 'mochi_dm_styles.dart';

class MochiDmTopBar extends StatelessWidget {
  final String username;
  final VoidCallback onAddPressed;

  const MochiDmTopBar({
    super.key,
    required this.username,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            const SizedBox(width: 44),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: MochiDmStyles.primaryText,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: MochiDmStyles.primaryText,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add, size: 24),
              color: MochiDmStyles.primaryText,
            ),
          ],
        ),
      ),
    );
  }
}
