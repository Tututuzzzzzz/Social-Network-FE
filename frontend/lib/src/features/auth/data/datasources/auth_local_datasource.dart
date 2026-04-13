import '../../../../core/errors/exceptions.dart';
import '../../../../core/cache/hive_local_storage.dart';
import '../../../../core/cache/secure_local_storage.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

sealed class AuthLocalDataSource {
  Future<UserEntity> checkSignInStatus();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureLocalStorage _secureLocalStorage;
  final HiveLocalStorage _localStorage;
  const AuthLocalDataSourceImpl(this._secureLocalStorage, this._localStorage);

  @override
  Future<UserEntity> checkSignInStatus() async {
    try {
      final userId = await _secureLocalStorage.load(key: "user_id") as String?;
      final result = await _localStorage.load(key: "user", boxName: "cache");
      if (result != null && (userId?.isNotEmpty ?? false)) {
        if (result is UserEntity) {
          return result;
        }

        if (result is Map) {
          final json = result.map(
            (key, value) => MapEntry(key.toString(), value),
          );
          return UserModel.fromJson(json);
        }
      }

      throw CacheException();
    } catch (e) {
      logger.e(e);
      throw CacheException();
    }
  }
}
