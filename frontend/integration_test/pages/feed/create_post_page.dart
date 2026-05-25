import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import '../../core/base_page.dart';

class CreatePostPage extends BasePage {
  CreatePostPage(super.tester);

  /// Điều hướng tới màn hình Tạo Bài đăng qua thanh Bottom Navigation Bar
  Future<void> navigateToCreatePost() async {
    final navCreateFinder = find.byKey(TestKeys.navCreate);
    if (navCreateFinder.evaluate().isNotEmpty) {
      await safeTap(navCreateFinder, warnIfMissed: true);
    }
  }

  /// Điền nội dung mô tả (caption) của bài viết mới
  Future<void> fillCaption(String text) async {
    await enterTextFieldText(TestKeys.createPostCaptionField, text);
  }

  /// Xác nhận gửi bài đăng mới lên máy chủ
  Future<void> submitPost() async {
    final submitButton = find.byKey(TestKeys.createPostSubmitButton);
    await safeTap(submitButton, warnIfMissed: true);
  }
}
