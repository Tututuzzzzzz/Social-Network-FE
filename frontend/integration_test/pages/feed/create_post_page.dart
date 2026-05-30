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
      final navCreateInkWell = tester.widget<InkWell>(navCreateFinder);
      navCreateInkWell.onTap?.call();
      await tester.pumpAndSettle();
    }
  }

  /// Điền nội dung mô tả (caption) của bài viết mới
  Future<void> fillCaption(String text) async {
    await enterTextFieldText(TestKeys.createPostCaptionField, text);
  }

  /// Chọn ảnh đầu tiên từ thư viện để test flow đăng bài kèm media.
  Future<void> pickGalleryImage() async {
    await tap(find.byKey(TestKeys.createPostLibraryButton));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Xác nhận gửi bài đăng mới lên máy chủ
  Future<void> submitPost() async {
    final submitButton = find.byKey(TestKeys.createPostSubmitButton);
    await tap(submitButton);
    await tester.pumpAndSettle(const Duration(seconds: 4));
  }
}
