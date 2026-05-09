import 'dart:convert';

import '../../../../../configs/injector/injector_conf.dart';
import '../../../../../core/cache/hive_local_storage.dart';
import '../../../../../core/cache/secure_local_storage.dart';
import '../../../../../core/realtime/realtime_socket_service.dart';
import '../../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../../profile/data/models/profile_model.dart';
import '../../../../profile/domain/entities/profile_entity.dart';

class CreatePostIdentitySnapshot {
  const CreatePostIdentitySnapshot({
    this.userId = '',
    this.displayName = '',
    this.avatarUrl = '',
    this.profile,
  });

  final String userId;
  final String displayName;
  final String avatarUrl;
  final ProfileEntity? profile;

  bool get hasDisplayData {
    return displayName.trim().isNotEmpty ||
        avatarUrl.trim().isNotEmpty ||
        profile != null;
  }
}

class CreatePostIdentityResolver {
  const CreatePostIdentityResolver();

  CreatePostIdentitySnapshot fromAuthState(AuthState authState) {
    final user = switch (authState) {
      AuthLoginSuccessState(:final data) => data,
      AuthCheckSignInStatusSuccessState(:final data) => data,
      _ => null,
    };

    return CreatePostIdentitySnapshot(
      displayName: user?.userName?.trim() ?? '',
    );
  }

  Future<CreatePostIdentitySnapshot> loadInitialIdentity() async {
    final cachedIdentity = await _loadCachedUserIdentity();
    final userId = await _resolveCurrentUserId();
    final cachedProfile = userId.isEmpty ? null : await _loadCachedProfile(userId);

    return CreatePostIdentitySnapshot(
      userId: userId,
      displayName: cachedIdentity.displayName,
      avatarUrl: cachedIdentity.avatarUrl,
      profile: cachedProfile,
    );
  }

  Future<CreatePostIdentitySnapshot> _loadCachedUserIdentity() async {
    final localStorage = getIt<HiveLocalStorage>();
    final cachedUser = await localStorage.load(key: 'user', boxName: 'cache');

    if (cachedUser is! Map) {
      return const CreatePostIdentitySnapshot();
    }

    final user = _extractUserMap(cachedUser);
    final displayName = _firstText([
      user['displayName'],
      user['fullName'],
      user['name'],
      user['username'],
      user['userName'],
    ]);
    final avatarUrl = _firstText([
      user['avatarUrl'],
      user['avatar'],
      user['profileImage'],
    ]);

    return CreatePostIdentitySnapshot(
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }

  Future<ProfileEntity?> _loadCachedProfile(String userId) async {
    final localStorage = getIt<HiveLocalStorage>();
    final cached = await localStorage.load(
      key: 'profile_$userId',
      boxName: 'cache',
    );

    if (cached is! Map) {
      return null;
    }

    try {
      return ProfileModel.fromJson(Map<String, dynamic>.from(cached));
    } catch (_) {
      return null;
    }
  }

  Future<String> _resolveCurrentUserId() async {
    final secureStorage = getIt<SecureLocalStorage>();
    final storedUserId = (await secureStorage.load(key: 'user_id')).trim();
    if (storedUserId.isNotEmpty) {
      return storedUserId;
    }

    final socketUserId = (await getIt<RealtimeSocketService>().getCurrentUserId())
        .trim();
    if (socketUserId.isNotEmpty) {
      await secureStorage.save(key: 'user_id', value: socketUserId);
      return socketUserId;
    }

    final localStorage = getIt<HiveLocalStorage>();
    final cachedUser = await localStorage.load(key: 'user', boxName: 'cache');
    if (cachedUser is Map) {
      final user = _extractUserMap(cachedUser);
      final cachedUserId = _firstText([
        user['_id'],
        user['id'],
        user['userId'],
      ]);
      if (cachedUserId.isNotEmpty) {
        await secureStorage.save(key: 'user_id', value: cachedUserId);
        return cachedUserId;
      }
    }

    final tokenUserId = await _extractUserIdFromAccessToken();
    if (tokenUserId.isNotEmpty) {
      await secureStorage.save(key: 'user_id', value: tokenUserId);
      return tokenUserId;
    }

    return '';
  }

  Future<String> _extractUserIdFromAccessToken() async {
    final token =
        (await getIt<SecureLocalStorage>().load(key: 'access_token')).trim();
    if (token.isEmpty) {
      return '';
    }

    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return '';
      }

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload);
      if (decoded is! Map) {
        return '';
      }

      final map = decoded.map((key, value) {
        return MapEntry(key.toString(), value);
      });
      final userId = _firstText([
        map['userId'],
        map['id'],
        map['sub'],
        map['_id'],
        map['user_id'],
      ]);

      if (userId.isNotEmpty) {
        return userId;
      }

      final nestedUser = map['user'];
      if (nestedUser is Map) {
        final user = nestedUser.map((key, value) {
          return MapEntry(key.toString(), value);
        });
        return _firstText([user['_id'], user['id'], user['userId']]);
      }
    } catch (_) {
      return '';
    }

    return '';
  }

  Map<String, dynamic> _extractUserMap(Map<dynamic, dynamic> raw) {
    final map = raw.map((key, value) => MapEntry(key.toString(), value));
    final nestedUser = map['user'];
    if (nestedUser is Map) {
      return nestedUser.map((key, value) => MapEntry(key.toString(), value));
    }

    final nestedData = map['data'];
    if (nestedData is Map) {
      final data = nestedData.map((key, value) {
        return MapEntry(key.toString(), value);
      });
      final dataUser = data['user'];
      if (dataUser is Map) {
        return dataUser.map((key, value) {
          return MapEntry(key.toString(), value);
        });
      }
    }

    return map;
  }

  String _firstText(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }
}
