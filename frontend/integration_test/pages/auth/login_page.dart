import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import '../../core/base_page.dart';

class LoginPage extends BasePage {
  LoginPage(super.tester);

  /// Điền thông tin đăng nhập vào Form
  Future<void> fillLoginForm(String username, String password) async {
    await enterTextFieldText(TestKeys.loginUsernameField, username);
    await enterTextFieldText(TestKeys.loginPasswordField, password);
  }

  /// Gửi Form đăng nhập
  Future<void> submitLogin() async {
    final submitButton = find.byKey(TestKeys.loginSubmitButton);
    await tap(submitButton);
  }
}
