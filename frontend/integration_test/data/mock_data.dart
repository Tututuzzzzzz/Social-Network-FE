/// Dữ liệu giả lập dùng cho bộ test End-to-End (integration_test)
///
/// [MockData.stamp]: Timestamp tính bằng millisecond — đảm bảo mỗi lần chạy test
/// tạo ra username/email hoàn toàn độc nhất, tránh xung đột dữ liệu.
///
/// [Seed constants]: Tài khoản được seed cố định bởi backend (run-e2e-server.ts → seed.ts).
/// Những tài khoản này LUÔN tồn tại trong In-Memory DB khi E2E backend server khởi động.
class MockData {
  static final int stamp = DateTime.now().millisecondsSinceEpoch;

  /// Tạo email độc nhất — dùng domain @e2e.test (không tồn tại, tránh gửi email thật)
  static String generateEmail(String baseEmail) {
    if (baseEmail.isEmpty) return 'e2e_$stamp@e2e.test';
    // Nếu baseEmail có sẵn, chèn timestamp vào để không trùng
    final parts = baseEmail.split('@');
    return '${parts[0]}_$stamp@e2e.test';
  }

  /// Tạo username ngẫu nhiên độc nhất theo timestamp
  static String get username => 'e2e_$stamp';

  /// Thông tin cơ bản cho Form đăng ký
  static const String firstName = 'E2E';
  static const String lastName = 'Test';

  // ── Tài khoản Seed (từ backend seed.ts) ──────────────────────────────────────
  // Những tài khoản này được khởi tạo bởi run-e2e-server.ts trước khi Flutter test chạy.
  // Test E2E phụ thuộc vào sự tồn tại của chúng trong In-Memory DB.

  /// Tài khoản người dùng thông thường — được seed bởi seed.ts
  static const String seedUsername = 'seed_user';

  /// Tài khoản admin — được seed bởi seed.ts
  static const String seedAdminUsername = 'admin';

  /// Mật khẩu chung cho các tài khoản seed
  static const String seedPassword = 'Password123!';

  // ── Dữ liệu nội dung test ───────────────────────────────────────────────────

  /// Nội dung bình luận — có timestamp để dễ debug và không trùng lặp
  static String get commentText => 'E2E comment $stamp';

  /// Nội dung bài đăng — có timestamp để dễ debug và không trùng lặp
  static String get postText => 'E2E post $stamp';

  /// Nội dung tin nhắn chat
  static String get chatMessage => 'E2E hello $stamp';

  /// Tên hiển thị để cập nhật hồ sơ
  static String get displayName => 'E2E User $stamp';

  /// Bio để cập nhật hồ sơ
  static const String bio = 'Updated by E2E integration_test';
}
