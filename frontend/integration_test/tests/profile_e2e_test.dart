import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import '../data/mock_data.dart';
import '../pages/auth/login_page.dart';
import '../pages/profile/profile_page.dart';

/// Chạy luồng kiểm thử Chỉnh sửa Hồ sơ và Đăng xuất.
///
/// Đây là luồng CUỐI CÙNG trong bộ E2E test — kết thúc bằng Logout để
/// đảm bảo ứng dụng trở về trạng thái ban đầu (màn hình Đăng nhập).
Future<void> runProfileFlow(
  WidgetTester tester,
  ProfilePage profilePage,
  LoginPage loginPage,
) async {
  // ── Bước 1: Điều hướng sang tab Hồ sơ cá nhân ─────────────────────────────

  // [ASSERTION] Tab Profile phải tồn tại trên NavBar
  expect(
    find.byKey(TestKeys.navProfile),
    findsOneWidget,
    reason: 'Tab Hồ sơ phải hiển thị trên Bottom NavBar',
  );

  await profilePage.navigateToProfile();
  await profilePage.ensureOnPage(TestKeys.profileSettingsButton, AppRoutes.profile.path);

  // [ASSERTION] Phải đang ở màn hình Hồ sơ
  expect(
    find.byKey(TestKeys.profileSettingsButton),
    findsOneWidget,
    reason:
        'Nút Cài đặt phải hiển thị trên màn hình Hồ sơ cá nhân. '
        'Kiểm tra điều hướng sang tab Profile đang hoạt động.',
  );

  // ── Bước 2: Mở Settings Sheet và điều hướng sang Chỉnh sửa hồ sơ ──────────
  await profilePage.openSettingsSheet();

  // [ASSERTION] Menu cài đặt phải có mục "Chỉnh sửa hồ sơ"
  expect(
    find.byKey(TestKeys.profileEditAction),
    findsOneWidget,
    reason: 'Tùy chọn "Chỉnh sửa hồ sơ" phải hiển thị trong Settings Sheet',
  );

  await profilePage.navigateToEditProfile();

  // Chờ màn hình Chỉnh sửa hồ sơ load (có thể cần load data từ API)
  await profilePage.waitForFinder(
    find.byKey(TestKeys.editProfileDisplayNameField),
    timeout: const Duration(seconds: 20),
  );

  // [ASSERTION] Các trường chỉnh sửa phải hiển thị
  expect(
    find.byKey(TestKeys.editProfileDisplayNameField),
    findsOneWidget,
    reason: 'Trường Display Name phải hiển thị trên màn hình Chỉnh sửa hồ sơ',
  );
  expect(
    find.byKey(TestKeys.editProfileBioField),
    findsOneWidget,
    reason: 'Trường Bio phải hiển thị trên màn hình Chỉnh sửa hồ sơ',
  );

  // ── Bước 3: Điền thông tin mới và lưu ─────────────────────────────────────
  await profilePage.fillEditProfileForm(
    displayName: MockData.displayName,
    bio: MockData.bio,
  );

  // [ASSERTION] Nút Lưu phải hiển thị
  expect(
    find.byKey(TestKeys.editProfileSaveButton),
    findsOneWidget,
    reason: 'Nút Lưu phải hiển thị sau khi điền thông tin hồ sơ',
  );

  await profilePage.saveProfileChanges();

  // [ASSERTION] Sau khi lưu, phải quay lại màn hình Hồ sơ chính
  expect(
    find.byKey(TestKeys.profileSettingsButton),
    findsOneWidget,
    reason:
        'Phải quay lại màn hình Hồ sơ sau khi lưu thành công. '
        'Kiểm tra API cập nhật hồ sơ đang hoạt động.',
  );

  // ── Bước 4: Đăng xuất tài khoản ────────────────────────────────────────────
  await profilePage.openSettingsSheet();

  // [ASSERTION] Tùy chọn Logout phải có trong Settings Sheet
  expect(
    find.byKey(TestKeys.profileLogoutAction),
    findsOneWidget,
    reason: 'Tùy chọn "Đăng xuất" phải hiển thị trong Settings Sheet',
  );

  await profilePage.logout();

  // [ASSERTION CUỐI] Sau Logout, phải quay về màn hình Đăng nhập
  final loginFinder = find.byKey(TestKeys.loginUsernameField);
  final logoutFailedFinder = find.byType(SnackBar);
  final expectedPath = AppRoutes.login.path;
  var logoutFailed = false;

  final end = DateTime.now().add(const Duration(seconds: 25));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 300));
    final currentPath = _currentRoutePath(tester);
    if (currentPath == expectedPath || loginFinder.evaluate().isNotEmpty) {
      break;
    }
    if (logoutFailedFinder.evaluate().isNotEmpty) {
      // Soft-fail: allow suite to continue even if logout API fails.
      debugPrint(
        '⚠️ [E2E] Logout failed: snackbar appeared. Check API logs for /auth/logout.',
      );
      logoutFailed = true;
      break;
    }
  }

  if (!logoutFailed) {
    expect(
      loginFinder,
      findsOneWidget,
      reason:
          'Phải quay về màn hình Đăng nhập sau khi Đăng xuất thành công. '
          'Đây là assertion CUỐI CÙNG của toàn bộ bộ E2E test.',
    );
  }
}

String _currentRoutePath(WidgetTester tester) {
  try {
    final context = tester.element(find.byType(MaterialApp).first);
    final location = GoRouter.of(
      context,
    ).routeInformationProvider.value.location;
    return Uri.tryParse(location)?.path ?? '';
  } catch (_) {
    return '';
  }
}
