import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../configs/injector/injector_conf.dart';
import '../cache/secure_local_storage.dart';
import '../realtime/realtime_socket_service.dart';
import '../utils/logger.dart';
import 'api_constants.dart';

final ValueNotifier<bool> forceLogoutNotifier = ValueNotifier<bool>(false);

class ApiInterceptor extends Interceptor {
  final SecureLocalStorage _secureLocalStorage;
  const ApiInterceptor(this._secureLocalStorage);

  static const _retryFlagKey = '__retried_after_refresh__';

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
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    logger.e(statusCode);

    if (statusCode != 401) {
      super.onError(err, handler);
      return;
    }

    final options = err.requestOptions;
    final path = options.path;
    final hasRetried = options.extra[_retryFlagKey] == true;
    final isAuthFlow =
        path.contains(ApiConstants.login) ||
        path.contains(ApiConstants.register) ||
        path.contains(ApiConstants.refresh) ||
        path.contains(ApiConstants.logout);

    if (hasRetried || isAuthFlow) {
      await _clearSession();
      super.onError(err, handler);
      return;
    }

    try {
      final refreshedAccessToken = await _refreshAccessToken();
      if (refreshedAccessToken.isEmpty) {
        await _clearSession();
        super.onError(err, handler);
        return;
      }

      final retryDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          headers: {'Authorization': 'Bearer $refreshedAccessToken'},
        ),
      );

      final nextOptions = options.copyWith(
        extra: {...options.extra, _retryFlagKey: true},
      );

      final response = await retryDio.fetch(nextOptions);
      handler.resolve(response);
    } catch (_) {
      await _clearSession();
      super.onError(err, handler);
    }
  }

  Future<String> _refreshAccessToken() async {
    final refreshToken = await _secureLocalStorage.load(key: 'refresh_token');
    if (refreshToken.trim().isEmpty) {
      return '';
    }

    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    final response = await dio.post(
      ApiConstants.refresh,
      data: {'refreshToken': refreshToken},
    );

    final data = response.data;
    if (data is! Map) {
      return '';
    }

    final map = Map<String, dynamic>.from(data);
    final accessToken = map['accessToken']?.toString() ?? '';
    final nextRefreshToken = map['refreshToken']?.toString() ?? '';

    if (accessToken.isEmpty) {
      return '';
    }

    await _secureLocalStorage.save(key: 'access_token', value: accessToken);
    if (nextRefreshToken.isNotEmpty) {
      await _secureLocalStorage.save(
        key: 'refresh_token',
        value: nextRefreshToken,
      );
    }

    return accessToken;
  }

  Future<void> _clearSession() async {
    // Disconnect socket trước khi xóa credentials
    getIt<RealtimeSocketService>().disconnect();

    await _secureLocalStorage.delete(key: 'access_token');
    await _secureLocalStorage.delete(key: 'refresh_token');
    await _secureLocalStorage.delete(key: 'user_id');
    forceLogoutNotifier.value = true;
  }
}
