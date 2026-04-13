import '../../domain/entities/user_entity.dart';

class RegisterModel extends UserEntity {
  final String firstName;
  final String lastName;

  const RegisterModel({
    required this.firstName,
    required this.lastName,
    required String userName,
    required String email,
    required String password,
  }) : super(userName: userName, email: email, password: password);

  factory RegisterModel.fromEntity(UserEntity entity) {
    return RegisterModel(
      firstName: '',
      lastName: '',
      userName: entity.userName ?? '',
      email: entity.email ?? '',
      password: entity.password ?? '',
    );
  }

  RegisterModel copyWith({
    String? firstName,
    String? lastName,
    String? userName,
    String? email,
    String? password,
  }) {
    return RegisterModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userName: userName ?? this.userName ?? '',
      email: email ?? this.email ?? '',
      password: password ?? this.password ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'username': userName,
      'email': email,
      'password': password,
    };
  }
}
