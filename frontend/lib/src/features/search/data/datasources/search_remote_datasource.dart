import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/search_model.dart';

abstract class SearchRemoteDataSource {
  Future<SearchResponseModel> searchUsers({
    required String name,
    required int page,
    required int limit,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiHelper _apiHelper;

  const SearchRemoteDataSourceImpl(this._apiHelper);

  @override
  Future<SearchResponseModel> searchUsers({
    required String name,
    required int page,
    required int limit,
  }) async {
    try {
      final query = Uri(
        queryParameters: {
          'name': name,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      ).query;

      final endpoint = '${ApiConstants.usersSearch}?$query';
      final response = await _apiHelper.execute(
        method: Method.get,
        url: endpoint,
      );

      return SearchResponseModel.fromJson(response);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }
}
