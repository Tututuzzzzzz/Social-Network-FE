import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import '../../core/base_page.dart';

class SearchPage extends BasePage {
  SearchPage(super.tester);

  /// Tìm kiếm người dùng dựa trên từ khóa/tên đăng nhập
  Future<void> searchUser(String query) async {
    await enterTextFieldText(TestKeys.searchTextField, query);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }


}
