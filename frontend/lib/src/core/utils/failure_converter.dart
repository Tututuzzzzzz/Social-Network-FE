import '../errors/failures.dart';

String mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return "Lỗi máy chủ. Vui lòng thử lại sau.";
    case CacheFailure:
      return "Lỗi kết nối mạng. Vui lòng kiểm tra kết nối của bạn.";
    case EmptyFailure:
      return "Không có dữ liệu nào được tìm thấy.";
    case CredentialFailure:
      return "Thông tin đăng nhập không chính xác. Vui lòng kiểm tra lại.";
    case DuplicateEmailFailure:
      return "Email đã tồn tại. Vui lòng sử dụng email khác.";
    case PasswordNotMatchFailure:
      return "Mật khẩu không khớp. Vui lòng kiểm tra lại.";
    case InvalidEmailFailure:
      return "Email không hợp lệ. Vui lòng nhập một email hợp lệ.";
    case InvalidUsernameFailure:
      return "Username không hợp lệ. Vui lòng nhập username.";
    case InvalidPasswordFailure:
      return "Mật khẩu không hợp lệ. Mật khẩu phải chứa ít nhất một chữ cái và một số.";
    default:
      return "Đã xảy ra lỗi không xác định. Vui lòng thử lại.";
  }
}
