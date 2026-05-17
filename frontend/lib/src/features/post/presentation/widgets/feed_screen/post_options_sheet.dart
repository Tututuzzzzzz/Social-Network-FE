import 'package:flutter/material.dart';
import 'package:frontend/src/features/post/domain/entities/post_entity.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/theme/app_colors.dart';

enum PostOptionAction { addToFavorites, aboutAccount, hidePost, report }

enum PostReportReason {
  spam,
  harassment,
  falseInfo,
  hateSpeech,
  violence,
  other,
}

String reportReasonLabel(PostReportReason reason, dynamic l10n) {
  switch (reason) {
    case PostReportReason.spam:
      return l10n.postReportReasonSpam;
    case PostReportReason.harassment:
      return l10n.postReportReasonHarassment;
    case PostReportReason.falseInfo:
      return l10n.postReportReasonFalseInfo;
    case PostReportReason.hateSpeech:
      return l10n.postReportReasonHateSpeech;
    case PostReportReason.violence:
      return l10n.postReportReasonViolence;
    case PostReportReason.other:
      return l10n.postReportReasonOther;
  }
}

String reportReasonValue(PostReportReason reason) {
  switch (reason) {
    case PostReportReason.spam:
      return 'spam';
    case PostReportReason.harassment:
      return 'harassment';
    case PostReportReason.falseInfo:
      return 'false_info';
    case PostReportReason.hateSpeech:
      return 'hate_speech';
    case PostReportReason.violence:
      return 'violence';
    case PostReportReason.other:
      return 'other';
  }
}

Future<PostOptionAction?> showPostOptionsSheet(
  BuildContext context,
  PostEntity post,
) {
  final l10n = context.l10n;
  final colors = AppColors.of(context);

  return showModalBottomSheet<PostOptionAction>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: colors.scrim,
    isScrollControlled: false,
    builder: (sheetContext) {
      final sheetColors = AppColors.of(sheetContext);
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: sheetColors.sheetSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 34,
                  height: 3,
                  decoration: BoxDecoration(
                    color: sheetColors.sheetHandle,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 10),
                _buildGroup(
                  colors: sheetColors,
                  children: [
                    _buildTile(
                      colors: sheetColors,
                      icon: Icons.star_border,
                      label: l10n.postOptionAddToFavorites,
                      onTap: () => Navigator.pop(
                        sheetContext,
                        PostOptionAction.addToFavorites,
                      ),
                    ),
                    _buildTile(
                      colors: sheetColors,
                      icon: Icons.person_search_outlined,
                      label: l10n.postOptionAboutThisAccount,
                      onTap: () => Navigator.pop(
                        sheetContext,
                        PostOptionAction.aboutAccount,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildGroup(
                  colors: sheetColors,
                  children: [
                    _buildTile(
                      colors: sheetColors,
                      icon: Icons.visibility_off_outlined,
                      label: l10n.postOptionHidePost,
                      onTap: () => Navigator.pop(
                        sheetContext,
                        PostOptionAction.hidePost,
                      ),
                    ),
                    _buildTile(
                      colors: sheetColors,
                      icon: Icons.report_gmailerrorred_outlined,
                      label: l10n.postOptionReport,
                      labelColor: sheetColors.error,
                      iconColor: sheetColors.error,
                      onTap: () =>
                          Navigator.pop(sheetContext, PostOptionAction.report),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildGroup({required AppColors colors, required List<Widget> children}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: colors.inputFill,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(children: children),
  );
}

Widget _buildTile({
  required AppColors colors,
  required IconData icon,
  required String label,
  Color? labelColor,
  Color? iconColor,
  required VoidCallback onTap,
}) {
  final resolvedLabelColor = labelColor ?? colors.textPrimary;
  final resolvedIconColor = iconColor ?? colors.textPrimary;
  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 17, color: resolvedIconColor),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 22 / 1.8,
              color: resolvedLabelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Future<PostReportReason?> showReportReasonSheet(BuildContext context) async {
  final l10n = context.l10n;
  final colors = AppColors.of(context);
  PostReportReason? selectedReason;

  return showModalBottomSheet<PostReportReason>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: colors.scrim,
    isScrollControlled: false,
    builder: (sheetContext) {
      final sheetColors = AppColors.of(sheetContext);
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: sheetColors.sheetSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 34,
                        height: 3,
                        decoration: BoxDecoration(
                          color: sheetColors.sheetHandle,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.postReportTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: sheetColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.postReportSelectReason,
                        style: TextStyle(
                          fontSize: 13,
                          color: sheetColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...PostReportReason.values.map((reason) {
                      final isSelected = selectedReason == reason;

                      return InkWell(
                        onTap: () => setSheetState(() {
                          selectedReason = reason;
                        }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                size: 20,
                                color: isSelected
                                    ? sheetColors.accent
                                    : sheetColors.textSecondary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                reportReasonLabel(reason, l10n),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: sheetColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              style: OutlinedButton.styleFrom(
                                shape: const StadiumBorder(),
                              ),
                              child: Text(l10n.cancel),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: selectedReason == null
                                  ? null
                                  : () => Navigator.pop(
                                      sheetContext,
                                      selectedReason,
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: sheetColors.error,
                                foregroundColor: sheetColors.appBarForeground,
                                shape: const StadiumBorder(),
                              ),
                              child: Text(l10n.postReportSubmit),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
