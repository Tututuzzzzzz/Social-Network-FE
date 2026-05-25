import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import '../../core/base_page.dart';

class ProfilePage extends BasePage {
  ProfilePage(super.tester);

  /// Điều hướng sang tab Hồ sơ cá nhân từ thanh Bottom Navigation Bar
  Future<void> navigateToProfile() async {
    final navProfileFinder = find.byKey(TestKeys.navProfile);
    if (navProfileFinder.evaluate().isNotEmpty) {
      await safeTap(navProfileFinder, warnIfMissed: true);
    }
  }

  /// Mở Bottom Sheet Cài đặt của Hồ sơ
  Future<void> openSettingsSheet() async {
    final settingsButtonFinder = find.byKey(TestKeys.profileSettingsButton);
    if (settingsButtonFinder.evaluate().isNotEmpty) {
      await safeTap(settingsButtonFinder, warnIfMissed: true);
    }
  }

  /// Điều hướng tới màn hình Chỉnh sửa hồ sơ
  Future<void> navigateToEditProfile() async {
    final profileEditActionFinder = find.byKey(TestKeys.profileEditAction);
    if (profileEditActionFinder.evaluate().isNotEmpty) {
      await safeTap(profileEditActionFinder, warnIfMissed: true);
    }
  }

  /// Điền thông tin thay đổi vào Form Chỉnh sửa hồ sơ
  Future<void> fillEditProfileForm({
    required String displayName,
    required String bio,
  }) async {
    await enterTextFieldText(TestKeys.editProfileDisplayNameField, displayName);
    await enterTextFieldText(TestKeys.editProfileBioField, bio);
  }

  /// Lưu các thay đổi của hồ sơ
  Future<void> saveProfileChanges() async {
    final editProfileSaveFinder = find.byKey(TestKeys.editProfileSaveButton);
    if (editProfileSaveFinder.evaluate().isNotEmpty) {
      await safeTap(editProfileSaveFinder, warnIfMissed: true);
    }
  }

  /// Thực hiện hành động Đăng xuất tài khoản
  Future<void> logout() async {
    final logoutButtonFinder = find.byKey(TestKeys.profileLogoutAction);
    if (logoutButtonFinder.evaluate().isNotEmpty) {
      await waitForFinder(
        logoutButtonFinder,
        timeout: const Duration(seconds: 10),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(logoutButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(logoutButtonFinder, warnIfMissed: false);
      await tester.pumpAndSettle();
    }
  }
}
