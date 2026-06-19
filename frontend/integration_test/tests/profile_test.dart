import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'package:integration_test/integration_test.dart';
import '../core/test_config.dart';
import '../pages/auth/login_page.dart';
import '../pages/profile/profile_page.dart';
import 'profile_e2e_test.dart';

/// Test độc lập cho luồng Profile — có thể chạy song song với các test khác.
///
/// Login bằng: e2e_admin (tài khoản riêng, không xung đột với test khác)
/// Luồng: Login → Mở Profile → Chỉnh sửa hồ sơ → Logout → Xác nhận về Login.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E Profile: edit + logout', (tester) async {
    final seedData = await TestConfig.setupTest(tester);
    final loginPage = LoginPage(tester);
    final profilePage = ProfilePage(tester);

    // Login bằng admin user — tránh xung đột với feed/notifications dùng e2e_user
    await loginPage.fillLoginForm(
      seedData.admin.username,
      seedData.admin.password,
    );
    await loginPage.submitLogin();
    await loginPage.waitForFinder(
      find.byKey(TestKeys.feedSearchButton),
      timeout: const Duration(seconds: 35),
    );

    await runProfileFlow(tester, profilePage, loginPage);
  });
}
