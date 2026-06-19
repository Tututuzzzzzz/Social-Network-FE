import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'package:integration_test/integration_test.dart';
import '../core/test_config.dart';
import '../pages/auth/login_page.dart';
import '../pages/feed/feed_page.dart';
import '../pages/search/search_page.dart';
import 'friends_e2e_test.dart';

/// Test độc lập cho luồng Friends — có thể chạy song song với các test khác.
///
/// Login bằng: e2e_requester (tài khoản riêng, không xung đột với test khác)
/// Luồng: Login → Search → Gửi friend request → Quay lại Feed.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E Friends: search + send request', (tester) async {
    final seedData = await TestConfig.setupTest(tester);
    final loginPage = LoginPage(tester);
    final feedPage = FeedPage(tester);
    final searchPage = SearchPage(tester);

    // Login bằng requester user — dùng riêng cho friends flow
    await loginPage.fillLoginForm(
      seedData.requester.username,
      seedData.requester.password,
    );
    await loginPage.submitLogin();
    await loginPage.waitForFinder(
      find.byKey(TestKeys.feedSearchButton),
      timeout: const Duration(seconds: 35),
    );

    await runFriendsFlow(
      tester,
      feedPage,
      searchPage,
      targetUsername: seedData.admin.username,
    );
  });
}
