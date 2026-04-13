import 'package:flutter/widgets.dart';
import 'package:frontend/src/l10n/generated/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
