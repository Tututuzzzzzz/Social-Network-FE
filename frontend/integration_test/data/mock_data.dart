class MockData {
  static final int stamp = DateTime.now().millisecondsSinceEpoch;

  /// Tạo email độc nhất dựa trên email nền
  static String generateEmail(String baseEmail) {
    if (baseEmail.isEmpty) return 'e2e_$stamp@example.com';
    return baseEmail.replaceFirst('@', '_$stamp@');
  }

  /// Tạo username ngẫu nhiên độc nhất
  static String get username => 'e2e_$stamp';

  /// Thông tin người dùng đăng ký mặc định
  static const String firstName = 'E2E';
  static const String lastName = 'Test';

  /// Dữ liệu bài đăng & bình luận mẫu
  static String get commentText => 'E2E comment $stamp';
  static String get postText => 'E2E post $stamp';
  static String get chatMessage => 'E2E hello';
  static String get displayName => 'E2E User $stamp';
  static const String bio = 'Updated by integration_test';
}
