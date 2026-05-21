import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import '../pages/feed/feed_page.dart';
import '../pages/search/search_page.dart';

/// Chạy kịch bản kiểm thử tích hợp liên quan tới tìm kiếm & kết bạn
Future<void> runFriendsFlow(
  WidgetTester tester,
  FeedPage feedPage,
  SearchPage searchPage,
) async {
  // 1. Điều hướng tới trang Tìm kiếm người dùng
  await feedPage.navigateToSearch();
  await searchPage.ensureOnPage(TestKeys.searchTextField, AppRoutes.homeSearch.path);

  // 2. Giả lập tìm kiếm một người dùng khác
  await searchPage.searchUser("admin");

  // 3. Chọn kết quả tìm kiếm đầu tiên nếu xuất hiện
  final userResultFinder = find.text("admin").first;
  if (userResultFinder.evaluate().isNotEmpty) {
    await searchPage.tap(userResultFinder);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 4. Tìm và kích hoạt nút thêm bạn bè bằng Icon
    final addFriendIconFinder = find.byIcon(Icons.person_add_alt_1_rounded);
    if (addFriendIconFinder.evaluate().isNotEmpty) {
      await searchPage.tap(addFriendIconFinder);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    // Quay lại màn hình tìm kiếm trước đó
    final backIconFinder = find.byIcon(Icons.arrow_back);
    if (backIconFinder.evaluate().isNotEmpty) {
      await searchPage.tap(backIconFinder.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  // 5. Quay lại trang bảng tin chính
  await searchPage.goBackToFeed(AppRoutes.home.path);
}
