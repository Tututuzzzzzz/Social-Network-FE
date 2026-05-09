import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';

enum ProfileSettingsAction { editProfile, logout }

Future<ProfileSettingsAction?> showProfileSettingsSheet(BuildContext context) {
  final l10n = context.l10n;

  return showModalBottomSheet<ProfileSettingsAction>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.18),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E3E7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.profileSettingsTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF14221D),
                      ),
                    ),
                  ),
                ),
                _ProfileSettingsTile(
                  icon: Icons.person_outline_rounded,
                  label: l10n.editProfileTitle,
                  onTap: () => Navigator.pop(
                    sheetContext,
                    ProfileSettingsAction.editProfile,
                  ),
                ),
                _ProfileSettingsTile(
                  icon: Icons.logout_rounded,
                  label: l10n.logoutAction,
                  labelColor: const Color(0xFFE53935),
                  iconColor: const Color(0xFFE53935),
                  onTap: () =>
                      Navigator.pop(sheetContext, ProfileSettingsAction.logout),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _ProfileSettingsTile extends StatelessWidget {
  const _ProfileSettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor = const Color(0xFF111111),
    this.iconColor = const Color(0xFF111111),
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color labelColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
