import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'package:integration_test/integration_test.dart';
import '../core/test_config.dart';
import '../pages/auth/login_page.dart';
import '../pages/feed/feed_page.dart';
import 'notifications_e2e_test.dart';

/// Test độc lập cho luồng Notifications — có thể chạy song song với các test khác.
///
/// Login bằng: e2e_user (primary — đã có notifications từ seed data)
/// Luồng: Login → Mở tab Notifications → Tương tác nếu có → Quay lại Feed.
///
/// Lưu ý: Test này chỉ ĐỌC notifications đã seed sẵn, không tạo data mới
/// nên không xung đột với test khác dùng cùng user (ví dụ feed_test).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E Notifications: view + interact', (tester) async {
    final seedData = await TestConfig.setupTest(tester);
    final loginPage = LoginPage(tester);
    final feedPage = FeedPage(tester);

    // Login bằng primary user — đã có notifications từ seed
    await loginPage.fillLoginForm(
      seedData.primary.username,
      seedData.primary.password,
    );
    await loginPage.submitLogin();
    await loginPage.waitForFinder(
      find.byKey(TestKeys.feedSearchButton),
      timeout: const Duration(seconds: 35),
    );

    await runNotificationsFlow(tester, feedPage);
  });
}
