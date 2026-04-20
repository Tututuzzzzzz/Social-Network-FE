import 'package:frontend/src/core/utils/logger.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/cache/local_storage.dart';
import '../models/profile_model.dart';

sealed class ProfileLocalDataSource {
  Future<ProfileModel> getProfile(String userId);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final LocalStorage _localStorage;
  const ProfileLocalDataSourceImpl(this._localStorage);

  @override
  Future<ProfileModel> getProfile(String userId) =>
      _getProfileFromCache(userId);

  Future<ProfileModel> _getProfileFromCache(String userId) async {
    try {
      final response = await _localStorage.load(
        key: "profile_$userId",
        boxName: "cache",
      );

      return ProfileModel.fromJson(response);
    } catch (e) {
      logger.e(e);
      throw CacheException();
    }
  }
}
