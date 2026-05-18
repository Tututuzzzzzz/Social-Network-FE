import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/cache/secure_local_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/login_model.dart';
import '../models/register_model.dart';
import '../models/user_model.dart';

sealed class AuthRemoteDataSource {
  Future<UserModel> login(LoginModel model);
  Future<void> logout();
  Future<String> refreshSession();
  Future<void> register(RegisterModel model);
  Future<void> forgotPassword(String email);
  Future<void> saveFcmToken(String token, String platform);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiHelper _apiHelper;
  final SecureLocalStorage _secureLocalStorage;
  const AuthRemoteDataSourceImpl(this._apiHelper, this._secureLocalStorage);

  @override
  Future<UserModel> login(LoginModel model) async {
    try {
      final result = await _apiHelper.execute(
        method: Method.post,
        url: ApiConstants.login,
        data: model.toJson(),
      );

      final accessToken = result['accessToken']?.toString() ?? '';
      final refreshToken = result['refreshToken']?.toString() ?? '';
      if (accessToken.isEmpty) {
        throw ServerException();
      }
      await _secureLocalStorage.save(key: 'access_token', value: accessToken);
      if (refreshToken.isNotEmpty) {
        await _secureLocalStorage.save(
          key: 'refresh_token',
          value: refreshToken,
        );
      }

      final payload = result['user'] ?? result;
      final json = payload is Map<String, dynamic>
          ? Map<String, dynamic>.from(payload)
          : payload is Map
          ? Map<String, dynamic>.from(payload)
          : <String, dynamic>{};

      final tokenPayload = _extractPayloadFromAccessToken(accessToken);
      final tokenUserId =
          tokenPayload?['userId'] ??
          tokenPayload?['sub'] ??
          tokenPayload?['_id'];
      final tokenUsername = tokenPayload?['username'];

      final userId = (json['_id'] ?? json['id'] ?? tokenUserId ?? '')
          .toString();

      return UserModel(
        userId: userId.isNotEmpty ? userId : null,
        userName: (json['username'] ?? result['username'] ?? tokenUsername)
            ?.toString(),
        email: json['email']?.toString(),
      );
    } on UnauthorisedException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      throw ServerException();
    }
  }

  @override
  Future<void> logout() async {
    try {
      // 1. XÓA FCM TOKEN TRƯỚC
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await _apiHelper.execute(
            method: Method.post,
            url: '/notifications/remove-fcm-token', 
            data: {'token': fcmToken},
          );
          logger.i("🧹 Đã dọn dẹp FCM Token trên Backend");
        }
        // Xóa luôn token lưu dưới cache của Firebase
        await FirebaseMessaging.instance.deleteToken();
      } catch (e) {
        logger.w("Không thể xóa FCM Token, nhưng vẫn tiếp tục đăng xuất: $e");
      }

      // 2. GỌI API LOGOUT CHÍNH THỨC
      final refreshToken = await _secureLocalStorage.load(key: 'refresh_token');
      
      // 👇 Dòng log này sẽ hoạt động như một "camera giám sát"
      logger.i("🔎 Refresh Token chuẩn bị gửi lên là: '$refreshToken'");

      try {
        // Chỉ gọi API sang Backend khi và chỉ khi token thực sự có dữ liệu
        if (refreshToken.trim().isNotEmpty) {
          await _apiHelper.execute(
            method: Method.post,
            url: ApiConstants.logout,
            data: {
              'refreshToken': refreshToken.trim(), 
            },
          );
          logger.i("✅ Gọi API Logout Backend thành công!");
        } else {
          logger.w("⚠️ Refresh Token bị trống, tự động bỏ qua bước gọi API Logout.");
        }
      } catch (_) {
        // Bỏ qua lỗi nếu session trên server đã hết hạn
      }
      return;
    } catch (e) {
      logger.e(e);
      throw ServerException();
    }
  }

  @override
  Future<String> refreshSession() async {
    try {
      final refreshToken = await _secureLocalStorage.load(key: 'refresh_token');
      if (refreshToken.trim().isEmpty) {
        throw AuthException();
      }

      final result = await _apiHelper.execute(
        method: Method.post,
        url: ApiConstants.refresh,
        data: {'refreshToken': refreshToken.trim()},
      );

      final payload = result['data'];
      final tokenMap = payload is Map<String, dynamic>
          ? payload
          : payload is Map
          ? Map<String, dynamic>.from(payload)
          : result;

      final accessToken =
          tokenMap['accessToken']?.toString() ??
          tokenMap['access_token']?.toString() ??
          '';
      final nextRefreshToken =
          tokenMap['refreshToken']?.toString() ??
          tokenMap['refresh_token']?.toString() ??
          '';

      if (accessToken.isEmpty) {
        throw AuthException();
      }

      await _secureLocalStorage.save(key: 'access_token', value: accessToken);
      if (nextRefreshToken.isNotEmpty) {
        await _secureLocalStorage.save(
          key: 'refresh_token',
          value: nextRefreshToken,
        );
      }

      return accessToken;
    } catch (e) {
      logger.e(e);
      throw AuthException();
    }
  }

  @override
  Future<void> register(RegisterModel model) async {
    try {
      await _apiHelper.execute(
        method: Method.post,
        url: ApiConstants.register,
        data: model.toJson(),
      );
      return;
    } on ConflictException {
      // Backend trả 409 khi username hoặc email đã tồn tại.
      throw DuplicateEmailException();
    } on UnprocessableEntityException {
      // Backend thường trả 422 khi email đã tồn tại.
      throw DuplicateEmailException();
    } catch (e) {
      logger.e(e);
      throw ServerException();
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _apiHelper.execute(
        method: Method.post,
        url: ApiConstants.forgotPassword,
        data: {'email': email},
      );
      return;
    } catch (e) {
      logger.e(e);
      throw ServerException();
    }
  }

  // 👇 ĐÂY LÀ HÀM MỚI ĐƯỢC THÊM VÀO
  @override
  Future<void> saveFcmToken(String token, String platform) async {
    try {
      await _apiHelper.execute(
        method: Method.post,
        url: ApiConstants.saveFcmToken, // Gọi đúng API lưu Token của Backend
        data: {
          'token': token,
          'platform': platform,
        },
      );
      logger.i("Đã gửi FCM Token lên Backend thành công!");
    } catch (e) {
      logger.e("Lỗi gửi FCM Token: $e");
      throw ServerException();
    }
  }

  Map<String, dynamic>? _extractPayloadFromAccessToken(String accessToken) {
    try {
      final parts = accessToken.split('.');
      if (parts.length < 2) {
        return null;
      }

      final payloadBase64 = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(payloadBase64));
      final decoded = jsonDecode(payload);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return decoded;
    } catch (_) {
      return null;
    }
  }
}