import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import '../pages/feed/feed_page.dart';

/// Chạy kịch bản kiểm thử luồng thông báo thời gian thực
Future<void> runNotificationsFlow(
  WidgetTester tester,
  FeedPage feedPage,
) async {
  // 1. Nhấn nút chuyển sang màn hình thông báo trên thanh Bottom NavBar
  final navNotificationsFinder = find.byKey(TestKeys.navNotifications);
  if (navNotificationsFinder.evaluate().isNotEmpty) {
    // Tự động chạm để di chuyển sang tab Notifications
    await tester.ensureVisible(navNotificationsFinder);
    await tester.pumpAndSettle();
    
    final navNotificationsInkWell = tester.widget<InkWell>(
      find.descendant(
        of: navNotificationsFinder,
        matching: find.byType(InkWell),
      ),
    );
    navNotificationsInkWell.onTap?.call();
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // 2. Chạm vào thông báo đầu tiên nếu có để kiểm tra sự kiện đã đọc
    final listTileFinder = find.byType(ListTile).first;
    if (listTileFinder.evaluate().isNotEmpty) {
      await tester.tap(listTileFinder);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    // 3. Quay lại trang bảng tin chính để tiếp tục các kịch bản khác
    final BuildContext context = tester.element(find.byType(MaterialApp).first);
    feedPage.goRouterGo(AppRoutes.home.path);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }
}
