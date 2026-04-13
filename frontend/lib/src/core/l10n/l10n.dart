import 'package:flutter/widgets.dart';
import 'package:frontend/src/l10n/generated/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n {
    final localizations = AppLocalizations.of(this);
    if (localizations != null) {
      return localizations;
    }

    final locale = Localizations.maybeLocaleOf(this) ?? const Locale('en');
    return lookupAppLocalizations(locale);
  }
}
