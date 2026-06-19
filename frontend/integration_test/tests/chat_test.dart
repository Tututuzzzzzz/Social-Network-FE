import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'package:integration_test/integration_test.dart';
import '../core/test_config.dart';
import '../pages/auth/login_page.dart';
import '../pages/chat/chat_page.dart';
import 'chat_e2e_test.dart';

/// Test độc lập cho luồng Chat — có thể chạy song song với các test khác.
///
/// Login bằng: e2e_friend (đã có friendship + conversation với e2e_user)
/// Luồng: Login → Mở Chat → Gửi tin nhắn → Quay lại Feed.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E Chat: send message', (tester) async {
    final seedData = await TestConfig.setupTest(tester);
    final loginPage = LoginPage(tester);
    final chatPage = ChatPage(tester);

    // Login bằng friend user — đã có conversation với e2e_user từ seed
    await loginPage.fillLoginForm(
      seedData.friend.username,
      seedData.friend.password,
    );
    await loginPage.submitLogin();
    await loginPage.waitForFinder(
      find.byKey(TestKeys.feedSearchButton),
      timeout: const Duration(seconds: 35),
    );

    await runChatFlow(tester, chatPage);
  });
}
