import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class BasePage {
  final WidgetTester tester;

  BasePage(this.tester);

  /// Đợi một Finder xuất hiện trên màn hình (đồng bộ)
  Future<void> waitForFinder(
    Finder finder, {
    Duration timeout = const Duration(seconds: 25),
    Duration step = const Duration(milliseconds: 400),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(step);
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    throw TestFailure('Timeout waiting for $finder');
  }

  /// Shorthand: đợi widget với Key cụ thể xuất hiện
  Future<void> waitForKey(
    Key key, {
    Duration timeout = const Duration(seconds: 25),
  }) async {
    await waitForFinder(find.byKey(key), timeout: timeout);
  }

  /// Thử đợi một Finder xuất hiện và trả về kết quả bool (không crash)
  Future<bool> tryWaitForFinder(
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    Duration step = const Duration(milliseconds: 400),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(step);
      if (finder.evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// Thực hiện điều hướng trực tiếp qua GoRouter của ứng dụng
  void goRouterGo(String routePath) {
    final elementList = find.byType(Scaffold).evaluate();
    if (elementList.isNotEmpty) {
      final BuildContext context = elementList.last;
      GoRouter.of(context).go(routePath);
    }
  }

  /// Đảm bảo ứng dụng đang ở trên màn hình mong muốn (sử dụng GoRouter nếu không thấy trang)
  Future<void> ensureOnPage(
    Key pageWidgetKey,
    String routePath,
  ) async {
    await tester.pumpAndSettle();
    final finder = find.byKey(pageWidgetKey);
    if (finder.evaluate().isEmpty) {
      goRouterGo(routePath);
      await tester.pumpAndSettle();
    }
    await waitForFinder(finder, timeout: const Duration(seconds: 15));
  }

  /// Quay lại trang Feed một cách an toàn bằng cách tìm nút Back/Close và dùng GoRouter
  Future<void> goBackToFeed(String homeRoutePath) async {
    // 1. Thử tìm AppBar và tap nút back hoặc close bên trong nó
    final appBarFinder = find.byType(AppBar);
    if (appBarFinder.evaluate().isNotEmpty) {
      final iconsToTry = [Icons.arrow_back, Icons.arrow_back_ios, Icons.close];
      for (final icon in iconsToTry) {
        final iconFinder = find.descendant(
          of: appBarFinder,
          matching: find.byIcon(icon),
        );
        if (iconFinder.evaluate().isNotEmpty) {
          try {
            await tester.tap(iconFinder.first);
            // Chờ màn hình chuyển xong thay vì delay cứng
            await tester.pumpAndSettle();
            break; // Chỉ tap 1 lần
          } catch (_) {
            // Bỏ qua nếu tap lỗi
          }
        }
      }
    }

    // 2. Chuyển hướng bằng GoRouter để chắc chắn quay về Feed
    try {
      goRouterGo(homeRoutePath);
      // Flush animation frame, không delay cứng
      await tester.pumpAndSettle();
    } catch (e) {
      log('Lỗi khi goRouterGo: $e', name: 'E2E');
    }
  }

  /// Hàm nhập liệu chuẩn có tự động cuộn hiển thị và đóng bàn phím ảo
  Future<void> enterTextFieldText(
    Key key,
    String value,
  ) async {
    final finder = find.byKey(key);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder, warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.enterText(finder, value);
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  /// Hàm chạm (tap) có tự động cuộn hiển thị trước khi chạm
  Future<void> tap(
    Finder finder, {
    bool warnIfMissed = false,
  }) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder, warnIfMissed: warnIfMissed);
    await tester.pumpAndSettle();
  }
}
