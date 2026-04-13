import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    @JsonKey(name: '_id', readValue: _readUserId) super.userId,
    @JsonKey(name: 'username', readValue: _readUserName) super.userName,
    super.email,
    super.password,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      userId: entity.userId,
      userName: entity.userName,
      email: entity.email,
      password: entity.password,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      userName: userName,
      email: email,
      password: password,
    );
  }

  static Object? _readUserId(Map<dynamic, dynamic> json, String key) {
    return json['_id'] ?? json['id'];
  }

  static Object? _readUserName(Map<dynamic, dynamic> json, String key) {
    return json['username'] ?? json['userName'];
  }
}
