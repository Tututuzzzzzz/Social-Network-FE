import 'package:frontend/src/core/utils/logger.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/cache/local_storage.dart';
import '../models/get_post_model.dart';

sealed class PostLocalDatasource {
  Future<List<PostModel>> getAllPosts();
}

class PostLocalDatasourceImpl implements PostLocalDatasource {
  final LocalStorage _localStorage;
  const PostLocalDatasourceImpl(this._localStorage);

  @override
  Future<List<PostModel>> getAllPosts() => _getPostsFromCache();

  Future<List<PostModel>> _getPostsFromCache() async {
    try {
      final response = await _localStorage.load(key: "posts", boxName: "cache");

      return PostModel.fromMapList(response);
    } catch (e) {
      logger.e(e);
      throw CacheException();
    }
  }
}
