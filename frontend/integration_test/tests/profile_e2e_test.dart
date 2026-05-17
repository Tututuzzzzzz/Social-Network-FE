import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import '../data/mock_data.dart';
import '../pages/auth/login_page.dart';
import '../pages/profile/profile_page.dart';

/// Chạy luồng Chỉnh sửa Hồ sơ và Đăng xuất
Future<void> runProfileFlow(
  WidgetTester tester,
  ProfilePage profilePage,
  LoginPage loginPage,
) async {
  await profilePage.navigateToProfile();
  await profilePage.ensureOnPage(TestKeys.profileSettingsButton, AppRoutes.profile.path);

  await profilePage.openSettingsSheet();
  await profilePage.navigateToEditProfile();
  await profilePage.waitForFinder(
    find.byKey(TestKeys.editProfileDisplayNameField),
    timeout: const Duration(seconds: 20),
  );

  await profilePage.fillEditProfileForm(
    displayName: MockData.displayName,
    bio: MockData.bio,
  );
  await profilePage.saveProfileChanges();

  // [ASSERTION] Đảm bảo đã lưu thành công và quay lại màn hình Hồ sơ chính
  expect(find.byKey(TestKeys.profileSettingsButton), findsOneWidget);

  // 8. Luồng Đăng xuất tài khoản (Logout)
  await profilePage.openSettingsSheet();
  await profilePage.logout();

  await loginPage.waitForFinder(
    find.byKey(TestKeys.loginUsernameField),
    timeout: const Duration(seconds: 25),
  );

  // [ASSERTION] Đảm bảo đã quay lại màn hình Đăng nhập thành công
  expect(find.byKey(TestKeys.loginUsernameField), findsOneWidget);
}
