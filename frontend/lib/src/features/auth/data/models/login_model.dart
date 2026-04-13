import '../../domain/entities/user_entity.dart';

class LoginModel extends UserEntity {
  const LoginModel({required String username, required String password})
    : super(userName: username, password: password);

  factory LoginModel.fromEntity(UserEntity entity) {
    return LoginModel(
      username: entity.userName ?? '',
      password: entity.password ?? '',
    );
  }

  LoginModel copyWith({String? username, String? password}) {
    return LoginModel(
      username: username ?? this.userName ?? '',
      password: password ?? this.password ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': userName, 'password': password};
  }
}
