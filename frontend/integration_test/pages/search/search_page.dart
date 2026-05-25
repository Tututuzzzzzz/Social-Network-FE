import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import '../../core/base_page.dart';

class SearchPage extends BasePage {
  SearchPage(super.tester);

  /// Tìm kiếm người dùng dựa trên từ khóa/tên đăng nhập
  Future<void> searchUser(String query) async {
    await enterTextFieldText(TestKeys.searchTextField, query);
  }

  /// Quay lại trang Feed từ trang Tìm kiếm
  Future<void> goBackToFeed(String homeRoutePath) async {
    final appBarFinder = find.byType(AppBar);
    final backIconFinder = find.descendant(
      of: appBarFinder,
      matching: find.byIcon(Icons.arrow_back),
    );
    if (backIconFinder.evaluate().isNotEmpty) {
      final iconButtonFinder = find.ancestor(
        of: backIconFinder,
        matching: find.byType(IconButton),
      );
      if (iconButtonFinder.evaluate().isNotEmpty) {
        await safeTap(iconButtonFinder.first, warnIfMissed: true);
        return;
      }
    }
    // Fallback nếu không thấy nút bấm
    goRouterGo(homeRoutePath);
    await tester.pumpAndSettle();
  }
}
