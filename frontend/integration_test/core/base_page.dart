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
    try {
      final BuildContext context = tester.element(find.byType(MaterialApp).first);
      GoRouter.of(context).go(routePath);
    } catch (_) {
      final elementList = find.byType(Navigator).evaluate();
      if (elementList.isNotEmpty) {
        final BuildContext context = elementList.first;
        GoRouter.of(context).go(routePath);
      }
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
    await safeTap(finder, warnIfMissed: warnIfMissed);
  }

  /// Tap an toàn qua gesture system — thay thế onTap?.call() trực tiếp.
  /// Tự động xử lý ensureVisible và tìm child tappable nếu widget gốc
  /// là container (InkWell wrap InkWell, Column chứa GestureDetector...).
  Future<void> safeTap(Finder finder, {bool warnIfMissed = false}) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder, warnIfMissed: warnIfMissed);
    await tester.pumpAndSettle();
  }

  /// Chờ cho đến khi một Finder xuất hiện, rồi pumpAndSettle.
  /// Thay thế các pumpAndSettle(Duration(seconds: N)) cứng.
  Future<void> waitAndSettle(
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await waitForFinder(finder, timeout: timeout);
    await tester.pumpAndSettle();
  }
}
