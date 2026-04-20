import 'package:fpdart/fpdart.dart';

import '../../../../core/cache/hive_local_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_checker.dart';
import '../../../post/domain/entities/post_entity.dart';
import '../../../post/data/models/get_post_model.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/usecase_params.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final ProfileLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final HiveLocalStorage _localStorage;

  const ProfileRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
    this._localStorage,
  );

  @override
  Future<Either<Failure, ProfileEntity>> getProfile(ProfileParams params) =>
      _networkInfo.check(
        connected: () async {
          try {
            final result = await _remoteDataSource.fetchProfile(params.userId);
            await _localStorage.save(
              key: 'profile_${params.userId}',
              boxName: 'cache',
              value: result.toJson(),
            );
            return Right(result);
          } on ServerException {
            return Left(ServerFailure());
          }
        },
        notConnected: () async {
          try {
            final cached = await _localDataSource.getProfile(params.userId);
            return Right(cached);
          } on CacheException {
            return Left(CacheFailure());
          }
        },
      );

  @override
  Future<Either<Failure, List<PostEntity>>> getUserPosts(
    GetUserPostsParams params,
  ) => _networkInfo.check(
    connected: () async {
      try {
        final result = await _remoteDataSource.fetchUserPosts(
          params.userId,
          page: params.page,
          limit: params.limit,
        );
        await _localStorage.save(
          key: _postsCacheKey(params),
          boxName: 'cache',
          value: result.map((e) => e.toJson()).toList(),
        );
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    },
    notConnected: () async {
      try {
        final cachedRaw = await _localStorage.load(
          key: _postsCacheKey(params),
          boxName: 'cache',
        );

        if (cachedRaw is! List) {
          throw CacheException();
        }

        final posts = cachedRaw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .map(PostModel.fromJson)
            .cast<PostEntity>()
            .toList();

        return Right(posts);
      } on CacheException {
        return Left(CacheFailure());
      } catch (_) {
        return Left(CacheFailure());
      }
    },
  );

  String _postsCacheKey(GetUserPostsParams params) =>
      'user_posts_${params.userId}_${params.page}_${params.limit}';

  @override
  Future<Either<Failure, void>> updateProfile(UpdateProfileParams params) =>
      _networkInfo.check(
        connected: () async {
          try {
            await _remoteDataSource.updateProfile(
              displayName: params.displayName,
              bio: params.bio,
              phone: params.phone,
            );
            return const Right(null);
          } on ServerException {
            return Left(ServerFailure());
          }
        },
        notConnected: () async => Left(CacheFailure()),
      );

  @override
  Future<Either<Failure, void>> updateAvatar(UpdateAvatarParams params) =>
      _networkInfo.check(
        connected: () async {
          try {
            await _remoteDataSource.updateAvatar(
              avatarBytes: params.avatarBytes,
              fileName: params.fileName,
            );
            return const Right(null);
          } on ServerException {
            return Left(ServerFailure());
          }
        },
        notConnected: () async => Left(CacheFailure()),
      );
}
