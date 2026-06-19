import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'package:integration_test/integration_test.dart';
import '../core/test_config.dart';
import '../pages/auth/login_page.dart';
import '../pages/feed/feed_page.dart';
import '../pages/feed/create_post_page.dart';
import '../pages/search/search_page.dart';
import 'feed_e2e_test.dart';

/// Test độc lập cho luồng Feed — có thể chạy song song với các test khác.
///
/// Login bằng: e2e_user (primary seed user)
/// Luồng: Login → Tạo post → Like → Comment → Search → Quay lại Feed.
/// Data tạo ra có flowStamp riêng nên không xung đột với test khác.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E Feed: create post, like, comment, search', (tester) async {
    final seedData = await TestConfig.setupTest(tester);
    final loginPage = LoginPage(tester);
    final feedPage = FeedPage(tester);
    final searchPage = SearchPage(tester);
    final createPostPage = CreatePostPage(tester);

    // Login bằng seed primary user
    await loginPage.fillLoginForm(
      seedData.primary.username,
      seedData.primary.password,
    );
    await loginPage.submitLogin();
    await loginPage.waitForFinder(
      find.byKey(TestKeys.feedSearchButton),
      timeout: const Duration(seconds: 35),
    );

    await runFeedFlow(
      tester,
      feedPage,
      searchPage,
      createPostPage,
      seedData.primary.username,
    );
  });
}
