import 'package:frontend/src/core/utils/regex_validator.dart';

extension StringValidatorExtension on String {
  bool get isValidEmail => RegexValidator.email.hasMatch(this);

  bool get isValidPassword => RegexValidator.password.hasMatch(this);
}
