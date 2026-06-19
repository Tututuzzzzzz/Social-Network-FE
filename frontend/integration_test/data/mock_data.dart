import 'dart:io' show pid;

/// Dữ liệu giả lập dùng cho bộ test End-to-End (integration_test)
///
/// [MockData.flowStamp]: Kết hợp timestamp + process ID — đảm bảo mỗi lần chạy test
/// và mỗi process chạy đồng thời đều tạo ra dữ liệu hoàn toàn độc nhất.
///
/// [Seed constants]: Tài khoản được seed cố định bởi backend (run-e2e-server.ts → e2e-seed.ts).
/// Những tài khoản này LUÔN tồn tại trong In-Memory DB khi E2E backend server khởi động.
class MockData {
  /// Unique stamp per test process — tránh xung đột khi chạy đồng thời
  /// Kết hợp timestamp + pid để chắc chắn không trùng giữa 2 process cùng lúc
  static final String flowStamp = '${DateTime.now().millisecondsSinceEpoch}_$pid';

  /// Tạo email độc nhất — dùng domain @e2e.test (không tồn tại, tránh gửi email thật)
  static String generateEmail(String baseEmail) {
    if (baseEmail.isEmpty) return 'e2e_$flowStamp@e2e.test';
    // Nếu baseEmail có sẵn, chèn timestamp vào để không trùng
    final parts = baseEmail.split('@');
    return '${parts[0]}_$flowStamp@e2e.test';
  }

  /// Tạo username ngẫu nhiên độc nhất theo timestamp + pid
  static String get username => 'e2e_$flowStamp';

  /// Thông tin cơ bản cho Form đăng ký
  static const String firstName = 'E2E';
  static const String lastName = 'Test';

  // ── Tài khoản Seed (từ backend e2e-seed.ts) ────────────────────────────────
  // Những tài khoản này được khởi tạo bởi run-e2e-server.ts trước khi Flutter test chạy.
  // Test E2E phụ thuộc vào sự tồn tại của chúng trong In-Memory DB.

  /// Tài khoản người dùng thông thường — được seed bởi e2e-seed.ts
  static const String seedUsername = 'e2e_user';

  /// Tài khoản admin — được seed bởi e2e-seed.ts
  static const String seedAdminUsername = 'e2e_admin';

  /// Mật khẩu chung cho các tài khoản seed
  static const String seedPassword = 'Password123!';

  // ── Dữ liệu nội dung test ───────────────────────────────────────────────────

  /// Nội dung bình luận — có flowStamp để dễ debug và không trùng lặp
  static String get commentText => 'E2E comment $flowStamp';

  /// Nội dung bài đăng — có flowStamp để dễ debug và không trùng lặp
  static String get postText => 'E2E post $flowStamp';

  /// Nội dung bài đăng có ảnh — dùng riêng cho flow upload media
  static String get postImageText => 'E2E image post $flowStamp';

  /// Nội dung tin nhắn chat
  static String get chatMessage => 'E2E hello $flowStamp';

  /// Tên hiển thị để cập nhật hồ sơ
  static String get displayName => 'E2E User $flowStamp';

  /// Bio để cập nhật hồ sơ
  static const String bio = 'Updated by E2E integration_test';
}
