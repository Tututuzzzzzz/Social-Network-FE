import 'package:flutter/material.dart';

class AppColors {
  const AppColors({
    required this.primary,
    required this.scaffold,
    required this.appBar,
    required this.appBarForeground,
    required this.sheetSurface,
    required this.sheetHandle,
    required this.title,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.scrim,
    required this.navBackground,
    required this.navBorder,
    required this.navActive,
    required this.navInactive,
    required this.badge,
    required this.badgeBorder,
    required this.chipFollowingBg,
    required this.chipFollowBg,
    required this.chipFollowingText,
    required this.chipFollowText,
    required this.subtleBorder,
    required this.placeholderIcon,
    required this.placeholderText,
    required this.inputFill,
    required this.inputBorder,
    required this.error,
    required this.authBackground,
    required this.authInputFill,
    required this.authInputBorder,
    required this.authInputText,
    required this.authInputHint,
    required this.authPrimaryAction,
    required this.authDisabledAction,
    required this.authLink,
    required this.authDivider,
    required this.authGoogleButton,
    required this.authGoogleBorder,
    required this.authIcon,
    required this.authTitle,
    required this.authBody,
    required this.avatarPlaceholder,
    required this.postDetailSurface,
    required this.postDetailText,
    required this.postDetailSubtleText,
    required this.postDetailDivider,
    required this.postDetailLink,
    required this.mediaBackground,
    required this.likeActive,
  });

  final Color primary;
  final Color scaffold;
  final Color appBar;
  final Color appBarForeground;
  final Color sheetSurface;
  final Color sheetHandle;
  final Color title;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color scrim;
  final Color navBackground;
  final Color navBorder;
  final Color navActive;
  final Color navInactive;
  final Color badge;
  final Color badgeBorder;
  final Color chipFollowingBg;
  final Color chipFollowBg;
  final Color chipFollowingText;
  final Color chipFollowText;
  final Color subtleBorder;
  final Color placeholderIcon;
  final Color placeholderText;
  final Color inputFill;
  final Color inputBorder;
  final Color error;
  final Color authBackground;
  final Color authInputFill;
  final Color authInputBorder;
  final Color authInputText;
  final Color authInputHint;
  final Color authPrimaryAction;
  final Color authDisabledAction;
  final Color authLink;
  final Color authDivider;
  final Color authGoogleButton;
  final Color authGoogleBorder;
  final Color authIcon;
  final Color authTitle;
  final Color authBody;
  final Color avatarPlaceholder;
  final Color postDetailSurface;
  final Color postDetailText;
  final Color postDetailSubtleText;
  final Color postDetailDivider;
  final Color postDetailLink;
  final Color mediaBackground;
  final Color likeActive;

  static const AppColors light = AppColors(
    primary: Color(0xFF31B991),
    scaffold: Color(0xFFF3F7F5),
    appBar: Color(0xFF31B991),
    appBarForeground: Colors.white,
    sheetSurface: Colors.white,
    sheetHandle: Color(0xFFE0E3E7),
    title: Color(0xFF14221D),
    textPrimary: Color(0xFF111111),
    textSecondary: Color(0xFF7A8580),
    accent: Color(0xFF31B991),
    scrim: Color(0x2E000000),
    navBackground: Colors.white,
    navBorder: Color(0xFFE2E2E7),
    navActive: Color(0xFF2FC48F),
    navInactive: Color(0xFF8A8A90),
    badge: Color(0xFFE53935),
    badgeBorder: Colors.white,
    chipFollowingBg: Color(0xFFE9E9EB),
    chipFollowBg: Color(0xFF2FC48F),
    chipFollowingText: Color(0xFF202025),
    chipFollowText: Colors.white,
    subtleBorder: Color(0xFFEEEEEE),
    placeholderIcon: Color(0xFF607D8B),
    placeholderText: Color(0xFF616161),
    inputFill: Color(0xFFF5F6F8),
    inputBorder: Color(0xFFD7DBE0),
    error: Color(0xFFE53935),
    authBackground: Colors.white,
    authInputFill: Color(0xFFF5F5F5),
    authInputBorder: Colors.transparent,
    authInputText: Color(0xFF111111),
    authInputHint: Color(0xFF8A8A90),
    authPrimaryAction: Color(0xFF3CC18E),
    authDisabledAction: Color(0xFFB7BBC1),
    authLink: Color(0xFF3797EF),
    authDivider: Color(0xFFE0E0E0),
    authGoogleButton: Colors.white,
    authGoogleBorder: Color(0xFFE0E0E0),
    authIcon: Color(0xFF111111),
    authTitle: Color(0xFF111111),
    authBody: Color(0x8A000000),
    avatarPlaceholder: Color(0xFFD7DADB),
    postDetailSurface: Color(0xFF242526),
    postDetailText: Colors.white,
    postDetailSubtleText: Color(0xFFE4E6EB),
    postDetailDivider: Color(0xFF18191A),
    postDetailLink: Color(0xFF4599FF),
    mediaBackground: Colors.black,
    likeActive: Color(0xFFFF4D6D),
  );

  static const AppColors dark = AppColors(
    primary: Color(0xFF3CCFA0),
    scaffold: Color(0xFF0F1113),
    appBar: Color(0xFF3CCFA0),
    appBarForeground: Color(0xFF0F1113),
    sheetSurface: Color(0xFF15181B),
    sheetHandle: Color(0xFF2B3036),
    title: Color(0xFFE6E6E6),
    textPrimary: Color(0xFFE6E6E6),
    textSecondary: Color(0xFF9AA0A6),
    accent: Color(0xFF3CCFA0),
    scrim: Color(0x59000000),
    navBackground: Color(0xFF121417),
    navBorder: Color(0xFF1E2328),
    navActive: Color(0xFF3CCFA0),
    navInactive: Color(0xFF8A9099),
    badge: Color(0xFFEF5350),
    badgeBorder: Color(0xFF121417),
    chipFollowingBg: Color(0xFF2B3036),
    chipFollowBg: Color(0xFF3CCFA0),
    chipFollowingText: Color(0xFFE6E6E6),
    chipFollowText: Color(0xFF0B1110),
    subtleBorder: Color(0xFF1F2429),
    placeholderIcon: Color(0xFF7A8792),
    placeholderText: Color(0xFFA0A7AE),
    inputFill: Color(0xFF1B1F24),
    inputBorder: Color(0xFF2A2F36),
    error: Color(0xFFEF5350),
    authBackground: Color(0xFF0F1113),
    authInputFill: Color(0xFF1B1F24),
    authInputBorder: Color(0xFF2A2F36),
    authInputText: Color(0xFFEDEFF2),
    authInputHint: Color(0xFF8A9099),
    authPrimaryAction: Color(0xFF3CCFA0),
    authDisabledAction: Color(0xFF3A4148),
    authLink: Color(0xFF6AA8FF),
    authDivider: Color(0xFF2B3036),
    authGoogleButton: Color(0xFF15181B),
    authGoogleBorder: Color(0xFF2A2F36),
    authIcon: Color(0xFFEDEFF2),
    authTitle: Color(0xFFF5F5F5),
    authBody: Color(0xFFB0B3B8),
    avatarPlaceholder: Color(0xFF2B3036),
    postDetailSurface: Color(0xFF14171A),
    postDetailText: Color(0xFFF5F5F5),
    postDetailSubtleText: Color(0xFFB0B3B8),
    postDetailDivider: Color(0xFF1C2126),
    postDetailLink: Color(0xFF6AA8FF),
    mediaBackground: Color(0xFF000000),
    likeActive: Color(0xFFFF4D6D),
  );

  static AppColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}
