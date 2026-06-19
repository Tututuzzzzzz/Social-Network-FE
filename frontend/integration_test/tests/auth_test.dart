import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../core/test_config.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import 'auth_e2e_test.dart';

/// Test độc lập cho luồng Auth — có thể chạy song song với các test khác.
///
/// Luồng: Đăng ký tài khoản mới (nếu enableRegister) → Đăng nhập → Xác nhận vào Feed.
/// Dùng user ngẫu nhiên (flowStamp) nên không xung đột data với test khác.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E Auth: register + login', (tester) async {
    final seedData = await TestConfig.setupTest(tester);
    final registerPage = RegisterPage(tester);
    final loginPage = LoginPage(tester);
    final sessionData = <String, String>{};

    await runAuthFlow(
      tester,
      registerPage,
      loginPage,
      sessionData,
      seedData: seedData,
    );
  });
}
