import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import '../../core/base_page.dart';

class RegisterPage extends BasePage {
  RegisterPage(super.tester);

  /// Di chuyển từ màn hình Đăng nhập sang màn hình Đăng ký
  Future<void> navigateToRegister() async {
    if (find.byKey(TestKeys.registerFirstNameField).evaluate().isEmpty) {
      final registerLink = find.byKey(TestKeys.loginRegisterLink);
      if (registerLink.evaluate().isNotEmpty) {
        await tap(registerLink);
        await waitForFinder(find.byKey(TestKeys.registerFirstNameField));
      }
    }
  }

  /// Điền đầy đủ thông tin vào Form đăng ký
  Future<void> fillRegistrationForm({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    await enterTextFieldText(TestKeys.registerFirstNameField, firstName);
    await enterTextFieldText(TestKeys.registerLastNameField, lastName);
    await enterTextFieldText(TestKeys.registerUsernameField, username);
    await enterTextFieldText(TestKeys.registerEmailField, email);
    await enterTextFieldText(TestKeys.registerPasswordField, password);
    await enterTextFieldText(TestKeys.registerConfirmField, password);
  }

  /// Gửi Form đăng ký tài khoản
  Future<void> submitRegistration() async {
    final submitFinder = find.byKey(TestKeys.registerSubmitButton);
    await tap(submitFinder);
  }

  /// Click nút Bắt đầu khi Đăng ký thành công màn hình
  Future<bool> clickSuccessStart() async {
    final successButton = find.byKey(TestKeys.registerSuccessStartButton);
    final hasSuccess = await tryWaitForFinder(
      successButton,
      timeout: const Duration(seconds: 12),
    );
    if (hasSuccess) {
      await tap(successButton);
    }
    return hasSuccess;
  }
}
