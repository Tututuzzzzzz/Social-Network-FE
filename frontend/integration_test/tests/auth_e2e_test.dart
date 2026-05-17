import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import '../core/test_config.dart';
import '../data/mock_data.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';

/// Chạy luồng Đăng ký (nếu bật) và Đăng nhập
Future<void> runAuthFlow(
  WidgetTester tester,
  RegisterPage registerPage,
  LoginPage loginPage,
  Map<String, String> sessionData,
) async {
  String loginUsername = TestConfig.username.trim();
  String loginPassword = TestConfig.password.trim();

  // Luồng Đăng ký tài khoản ngẫu nhiên (nếu E2E_ENABLE_REGISTER = true)
  if (TestConfig.enableRegister) {
    TestConfig.requireEnv(TestConfig.baseEmail, 'E2E_EMAIL');
    expect(
      TestConfig.baseEmail.contains('@'),
      isTrue,
      reason: 'E2E_EMAIL must contain "@" (invalid email format)',
    );

    final fallbackPassword = loginPassword.isNotEmpty ? loginPassword : 'P@ssw0rd!';
    final registerPassword = TestConfig.registerPassword.trim().isNotEmpty
        ? TestConfig.registerPassword.trim()
        : fallbackPassword;

    final email = MockData.generateEmail(TestConfig.baseEmail);
    final username = MockData.username;

    await registerPage.navigateToRegister();
    await registerPage.fillRegistrationForm(
      firstName: MockData.firstName,
      lastName: MockData.lastName,
      username: username,
      email: email,
      password: registerPassword,
    );
    await registerPage.submitRegistration();

    final hasSuccess = await registerPage.clickSuccessStart();
    expect(
      hasSuccess,
      isTrue,
      reason: 'Đăng ký thất bại hoặc không thể kết nối tới máy chủ API tại [${TestConfig.apiHost}:${TestConfig.apiPort}]. '
          'Vui lòng kiểm tra lại cấu hình trong tệp .env.e2e hoặc đảm bảo Backend đã được khởi động và hoạt động bình thường.',
    );

    await registerPage.waitForFinder(
      find.byKey(TestKeys.loginUsernameField),
      timeout: const Duration(seconds: 25),
    );

    loginUsername = username;
    loginPassword = registerPassword;
  } else {
    TestConfig.requireEnv(TestConfig.username, 'E2E_USERNAME');
    TestConfig.requireEnv(TestConfig.password, 'E2E_PASSWORD');
  }

  // Lưu thông tin đăng nhập phục vụ các luồng test sau
  sessionData['username'] = loginUsername;
  sessionData['password'] = loginPassword;

  // Luồng Đăng nhập tài khoản
  await loginPage.fillLoginForm(loginUsername, loginPassword);
  await loginPage.submitLogin();
  await loginPage.waitForFinder(
    find.byKey(TestKeys.feedSearchButton),
    timeout: const Duration(seconds: 35),
  );

  // [ASSERTION] Đảm bảo đã đăng nhập và đang ở trang Feed chính
  expect(find.byKey(TestKeys.feedSearchButton), findsOneWidget);
}
