import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import '../../core/base_page.dart';

class SearchPage extends BasePage {
  SearchPage(super.tester);

  /// Tìm kiếm người dùng dựa trên từ khóa/tên đăng nhập
  Future<void> searchUser(String query) async {
    await enterTextFieldText(TestKeys.searchTextField, query);
    // Chờ kết quả tìm kiếm xuất hiện thay vì delay cứng 3s
    // tryWaitForFinder: không fail nếu không có kết quả, caller sẽ assert
    await tryWaitForFinder(
      find.byKey(TestKeys.searchTextField),
      timeout: const Duration(seconds: 5),
    );
  }


}
