import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

//lỗi máy chủ
class ServerFailure extends Failure {}

//lỗi kết nối mạng
class CacheFailure extends Failure {}

class EmptyFailure extends Failure {}

//sai thông tin đăng nhập
class CredentialFailure extends Failure {}

//email đã tồn tại
class DuplicateEmailFailure extends Failure {}

//mật khẩu không khớp
class PasswordNotMatchFailure extends Failure {}

//email không hợp lệ
class InvalidEmailFailure extends Failure {}

//username không hợp lệ
class InvalidUsernameFailure extends Failure {}

//mật khẩu không hợp lệ
class InvalidPasswordFailure extends Failure {}
