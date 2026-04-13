import '../errors/failures.dart';

String mapFailureToMessage(Failure failure) {
  switch (failure) {
    case ServerFailure _:
      return "Lỗi máy chủ. Vui lòng thử lại sau.";
    case CacheFailure _:
      return "Lỗi kết nối mạng. Vui lòng kiểm tra kết nối của bạn.";
    case EmptyFailure _:
      return "Không có dữ liệu nào được tìm thấy.";
    case CredentialFailure _:
      return "Thông tin đăng nhập không chính xác. Vui lòng kiểm tra lại.";
    case DuplicateEmailFailure _:
      return "Email đã tồn tại. Vui lòng sử dụng email khác.";
    case PasswordNotMatchFailure _:
      return "Mật khẩu không khớp. Vui lòng kiểm tra lại.";
    case InvalidEmailFailure _:
      return "Email không hợp lệ. Vui lòng nhập một email hợp lệ.";
    case InvalidUsernameFailure _:
      return "Username không hợp lệ. Vui lòng nhập username.";
    case InvalidPasswordFailure _:
      return "Mật khẩu không hợp lệ. Mật khẩu phải chứa ít nhất một chữ cái và một số.";
  }
}
