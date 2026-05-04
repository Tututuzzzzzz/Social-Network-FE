import '../../bloc/dashboard/admin_dashboard_state.dart';

String adminSectionTitle(AdminSection section) {
  switch (section) {
    case AdminSection.overview:
      return 'Tổng quan';
    case AdminSection.users:
      return 'Quản lý người dùng';
    case AdminSection.posts:
      return 'Quản lý bài viết';
    case AdminSection.reports:
      return 'Danh sách báo cáo';
  }
}

String adminSectionSubtitle(AdminSection section) {
  switch (section) {
    case AdminSection.overview:
      return 'Theo dõi mạng xã hội.';
    case AdminSection.users:
      return 'Các tài khoản.';
    case AdminSection.posts:
      return 'Các bài viết.';
    case AdminSection.reports:
      return 'Báo cáo.';
  }
}
