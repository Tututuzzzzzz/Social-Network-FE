import 'package:dio/dio.dart';

import '../cache/session_storage.dart';
import 'api_constants.dart';
import 'api_exception.dart';

class ApiClient {
  final Dio _dio;
  final SessionStorage _sessionStorage;

  ApiClient(this._dio, this._sessionStorage) {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _sessionStorage.readAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(() => _dio.get(path, queryParameters: queryParameters));
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    return _request(() => _dio.post(path, data: data));
  }

  Future<dynamic> patch(String path, {dynamic data}) async {
    return _request(() => _dio.patch(path, data: data));
  }

  Future<dynamic> delete(String path) async {
    return _request(() => _dio.delete(path));
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return response.data;
    } on DioException catch (error) {
      final response = error.response;
      if (response == null) {
        throw const ApiException('Khong the ket noi backend');
      }

      final data = response.data;
      var message = 'Request that bai';
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }

      throw ApiException(message, statusCode: response.statusCode);
    }
  }
}
