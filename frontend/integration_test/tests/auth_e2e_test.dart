import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import '../core/test_config.dart';
import '../data/mock_data.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';

/// Chạy luồng Đăng ký (nếu bật) và Đăng nhập.
///
/// Chiến lược:
/// - Nếu [TestConfig.enableRegister] = true: Tự đăng ký tài khoản mới với
///   username/email ngẫu nhiên (timestamp), sau đó đăng nhập bằng tài khoản đó.
/// - Nếu [TestConfig.enableRegister] = false: Đăng nhập bằng [TestConfig.username]
///   (mặc định là `seed_user` từ backend seed.ts).
///
/// Sau khi hoàn thành, [sessionData] sẽ chứa 'username' và 'password' của
/// tài khoản đang hoạt động để các luồng test tiếp theo sử dụng.
Future<void> runAuthFlow(
  WidgetTester tester,
  RegisterPage registerPage,
  LoginPage loginPage,
  Map<String, String> sessionData,
) async {
  String loginUsername = TestConfig.username.trim();
  String loginPassword = TestConfig.password.trim();

  // ── Luồng A1: Đăng ký tài khoản mới ────────────────────────────────────────
  if (TestConfig.enableRegister) {
    // Xác nhận email cơ sở đã được cấu hình trong .env.e2e
    TestConfig.requireEnv(TestConfig.baseEmail, 'E2E_EMAIL');
    expect(
      TestConfig.baseEmail.contains('@'),
      isTrue,
      reason: 'E2E_EMAIL phải có định dạng hợp lệ (chứa "@")',
    );

    // Ưu tiên dùng E2E_REGISTER_PASSWORD, fallback sang E2E_PASSWORD, rồi default
    final fallbackPassword = loginPassword.isNotEmpty ? loginPassword : 'Password123!';
    final registerPassword = TestConfig.registerPassword.trim().isNotEmpty
        ? TestConfig.registerPassword.trim()
        : fallbackPassword;

    // Tạo email và username hoàn toàn độc nhất qua timestamp — không trùng lặp
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

    // [ASSERTION] Màn hình thành công phải xuất hiện sau khi đăng ký
    final hasSuccess = await registerPage.clickSuccessStart();
    expect(
      hasSuccess,
      isTrue,
      reason:
          'Đăng ký thất bại — Kiểm tra backend đã khởi động tại '
          '[${TestConfig.apiHost}:${TestConfig.apiPort}] và seed.ts đã chạy thành công.',
    );

    // [ASSERTION] Sau khi đăng ký, phải tự động chuyển về màn hình Đăng nhập
    await registerPage.waitForFinder(
      find.byKey(TestKeys.loginUsernameField),
      timeout: const Duration(seconds: 25),
    );
    expect(
      find.byKey(TestKeys.loginUsernameField),
      findsOneWidget,
      reason: 'Phải chuyển về màn hình Đăng nhập sau khi đăng ký thành công',
    );

    loginUsername = username;
    loginPassword = registerPassword;
  } else {
    // ── Luồng A2: Đăng nhập bằng tài khoản seed từ backend ─────────────────
    TestConfig.requireEnv(TestConfig.username, 'E2E_USERNAME');
    TestConfig.requireEnv(TestConfig.password, 'E2E_PASSWORD');
  }

  // Lưu thông tin đăng nhập vào session để các luồng test sau sử dụng
  sessionData['username'] = loginUsername;
  sessionData['password'] = loginPassword;

  // ── Luồng A3: Đăng nhập ────────────────────────────────────────────────────
  await loginPage.fillLoginForm(loginUsername, loginPassword);
  await loginPage.submitLogin();

  // [ASSERTION] Sau đăng nhập phải chuyển sang màn hình Feed chính
  await loginPage.waitForFinder(
    find.byKey(TestKeys.feedSearchButton),
    timeout: const Duration(seconds: 35),
  );
  expect(
    find.byKey(TestKeys.feedSearchButton),
    findsOneWidget,
    reason:
        'Đăng nhập thất bại với username="$loginUsername" — '
        'Kiểm tra thông tin đăng nhập trong .env.e2e khớp với tài khoản trong DB.',
  );
}
