import 'package:dio/dio.dart';

import '../cache/secure_local_storage.dart';
import '../utils/logger.dart';
import 'api_constants.dart';

class ApiInterceptor extends Interceptor {
  final SecureLocalStorage _secureLocalStorage;
  const ApiInterceptor(this._secureLocalStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.baseUrl = ApiConstants.baseUrl;

    final accessToken = await _secureLocalStorage.load(key: 'access_token');
    if (accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e(err.response?.statusCode);
    super.onError(err, handler);
  }
}
