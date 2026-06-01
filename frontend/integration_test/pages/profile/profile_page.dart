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
      final navProfileInkWell = tester.widget<InkWell>(navProfileFinder);
      navProfileInkWell.onTap?.call();
      await tester.pumpAndSettle();
    }
  }

  /// Mở Bottom Sheet Cài đặt của Hồ sơ
  Future<void> openSettingsSheet() async {
    final settingsButtonFinder = find.byKey(TestKeys.profileSettingsButton);
    if (settingsButtonFinder.evaluate().isNotEmpty) {
      final settingsButton = tester.widget<IconButton>(settingsButtonFinder);
      settingsButton.onPressed?.call();
      await tester.pumpAndSettle();
    }
  }

  /// Điều hướng tới màn hình Chỉnh sửa hồ sơ
  Future<void> navigateToEditProfile() async {
    final profileEditActionFinder = find.byKey(TestKeys.profileEditAction);
    if (profileEditActionFinder.evaluate().isNotEmpty) {
      final editActionInkWell = tester.widget<InkWell>(
        find.descendant(
          of: profileEditActionFinder,
          matching: find.byType(InkWell),
        ),
      );
      editActionInkWell.onTap?.call();
      await tester.pumpAndSettle();
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
      final saveButton = tester.widget<FilledButton>(editProfileSaveFinder);
      saveButton.onPressed?.call();
      // Chờ quay về màn hình Profile thay vì delay cứng 4s
      await waitForKey(TestKeys.profileSettingsButton);
    }
  }

  /// Thực hiện hành động Đăng xuất tài khoản
  Future<void> logout() async {
    final logoutButtonFinder = find.byKey(TestKeys.profileLogoutAction);
    if (logoutButtonFinder.evaluate().isNotEmpty) {
      final logoutActionInkWell = tester.widget<InkWell>(
        find.descendant(
          of: logoutButtonFinder,
          matching: find.byType(InkWell),
        ),
      );
      logoutActionInkWell.onTap?.call();
      await tester.pumpAndSettle();
    }
  }
}
