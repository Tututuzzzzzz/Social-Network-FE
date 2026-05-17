import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/blocs/theme/theme_bloc.dart';
import 'package:frontend/src/core/blocs/theme/theme_event.dart';
import 'package:frontend/src/core/blocs/theme/theme_state.dart';
import 'package:frontend/src/core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/language_bloc.dart';
import 'package:frontend/src/core/testing/test_keys.dart';

enum ProfileSettingsAction { editProfile, logout }

Future<ProfileSettingsAction?> showProfileSettingsSheet(BuildContext context) {
  return showModalBottomSheet<ProfileSettingsAction>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.of(context).scrim,
    builder: (sheetContext) {
      final colors = AppColors.of(sheetContext);
      final textTheme = Theme.of(sheetContext).textTheme;

      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.sheetSurface,
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
                    color: colors.sheetHandle,
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
                    child: BlocBuilder<LanguageBloc, LanguageState>(
                      builder: (context, _) {
                        return Text(
                          context.l10n.profileSettingsTitle,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.title,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                BlocBuilder<LanguageBloc, LanguageState>(
                  builder: (context, _) {
                    return _ProfileSettingsTile(
                      icon: Icons.person_outline_rounded,
                      label: context.l10n.editProfileTitle,
                      onTap: () => Navigator.pop(
                        sheetContext,
                        ProfileSettingsAction.editProfile,
                      ),
                    );
                  },
                ),
                BlocBuilder<LanguageBloc, LanguageState>(
                  builder: (context, languageState) {
                    final languageL10n = context.l10n;
                    final languageCode =
                        languageState.locale?.languageCode ??
                        Localizations.localeOf(context).languageCode;

                    return _ProfileLanguageTile(
                      label: languageL10n.profileLanguageTitle,
                      selectedLabel: languageCode == 'en'
                          ? languageL10n.languageEnglish
                          : languageL10n.languageVietnamese,
                      selectedLanguageCode: languageCode,
                      onChanged: (locale) {
                        context.read<LanguageBloc>().add(
                          LanguageChanged(locale),
                        );
                      },
                    );
                  },
                ),
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    final themeL10n = context.l10n;
                    final isDarkMode = themeState.mode == ThemeMode.dark;

                    return _ProfileThemeTile(
                      label: themeL10n.themeModeLabel,
                      modeLabel: isDarkMode
                          ? themeL10n.themeDark
                          : themeL10n.themeLight,
                      isDarkMode: isDarkMode,
                      onChanged: (value) {
                        context.read<ThemeBloc>().add(
                              ThemeModeChanged(
                                value ? ThemeMode.dark : ThemeMode.light,
                              ),
                            );
                      },
                    );
                  },
                ),
                BlocBuilder<LanguageBloc, LanguageState>(
                  builder: (context, _) {
                    return _ProfileSettingsTile(
                      icon: Icons.logout_rounded,
                      label: context.l10n.logoutAction,
                      labelColor: const Color(0xFFE53935),
                      iconColor: const Color(0xFFE53935),
                      onTap: () => Navigator.pop(
                        sheetContext,
                        ProfileSettingsAction.logout,
                      ),
                    );
                  },
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

class _ProfileLanguageTile extends StatefulWidget {
  const _ProfileLanguageTile({
    required this.label,
    required this.selectedLabel,
    required this.selectedLanguageCode,
    required this.onChanged,
  });

  final String label;
  final String selectedLabel;
  final String selectedLanguageCode;
  final ValueChanged<Locale> onChanged;

  @override
  State<_ProfileLanguageTile> createState() => _ProfileLanguageTileState();
}

class _ProfileLanguageTileState extends State<_ProfileLanguageTile> {
  final GlobalKey _menuAnchorKey = GlobalKey();

  Future<void> _openLanguageMenu() async {
    final anchorContext = _menuAnchorKey.currentContext;
    if (anchorContext == null) return;

    final anchorBox = anchorContext.findRenderObject() as RenderBox?;
    final overlayBox = Navigator.of(context)
        .overlay
        ?.context
        .findRenderObject() as RenderBox?;
    if (anchorBox == null || overlayBox == null) return;

    final anchorOffset = anchorBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final anchorSize = anchorBox.size;

    final selected = await showMenu<Locale>(
      context: context,
      position: RelativeRect.fromLTRB(
        anchorOffset.dx,
        anchorOffset.dy + anchorSize.height + 6,
        overlayBox.size.width - anchorOffset.dx - anchorSize.width,
        overlayBox.size.height - anchorOffset.dy,
      ),
      items: [
        PopupMenuItem<Locale>(
          value: const Locale('vi'),
          child: _LanguageMenuItem(
            label: context.l10n.languageVietnamese,
            isSelected: widget.selectedLanguageCode == 'vi',
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('en'),
          child: _LanguageMenuItem(
            label: context.l10n.languageEnglish,
            isSelected: widget.selectedLanguageCode == 'en',
          ),
        ),
      ],
    );

    if (selected != null) {
      widget.onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openLanguageMenu,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.language_rounded,
              size: 22,
              color: AppColors.of(context).textPrimary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.of(context).textPrimary,
                    ),
              ),
            ),
            Row(
              key: _menuAnchorKey,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.selectedLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.of(context).accent,
                      ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.of(context).textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageMenuItem extends StatelessWidget {
  const _LanguageMenuItem({
    required this.label,
    required this.isSelected,
  });

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        if (isSelected)
          Icon(
            Icons.check_rounded,
            color: AppColors.of(context).accent,
            size: 20,
          ),
      ],
    );
  }
}

class _ProfileThemeTile extends StatelessWidget {
  const _ProfileThemeTile({
    required this.label,
    required this.modeLabel,
    required this.isDarkMode,
    required this.onChanged,
  });

  final String label;
  final String modeLabel;
  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.brightness_6_rounded,
            size: 22,
            color: AppColors.of(context).textPrimary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.of(context).textPrimary,
                  ),
            ),
          ),
          Text(
            modeLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.of(context).accent,
                ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: isDarkMode,
            activeColor: AppColors.of(context).accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ProfileSettingsTile extends StatelessWidget {
  const _ProfileSettingsTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final resolvedLabelColor = labelColor ?? colors.textPrimary;
    final resolvedIconColor = iconColor ?? colors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: resolvedIconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: resolvedLabelColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
