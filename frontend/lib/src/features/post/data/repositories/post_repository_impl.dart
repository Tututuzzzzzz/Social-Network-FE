import 'package:fpdart/fpdart.dart';

import '../../../../core/cache/hive_local_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_checker.dart';
import '../../domain/entities/post_comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/post_comments_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/usecase_params.dart';
import '../datasources/post_local_datasource.dart';
import '../datasources/post_remote_datasource.dart';
import '../models/models.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDatasource _postRemoteDatasource;
  final PostLocalDatasource _postLocalDatasource;
  final NetworkInfo _networkInfo;
  final HiveLocalStorage _localStorage;
  const PostRepositoryImpl(
    this._postRemoteDatasource,
    this._postLocalDatasource,
    this._networkInfo,
    this._localStorage,
  );

  @override
  Future<Either<Failure, List<PostEntity>>> getAll() => _networkInfo.check(
    connected: () async {
      try {
        final result = await _postRemoteDatasource.fetchPosts();
        await _localStorage.save(
          key: 'posts',
          boxName: 'cache',
          value: PostModel.toJsonList(result),
        );
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    },
    notConnected: () async {
      try {
        final cached = await _postLocalDatasource.getAllPosts();
        return Right(cached);
      } on CacheException {
        return Left(CacheFailure());
      }
    },
  );

  @override
  Future<Either<Failure, void>> create(CreatePostParams params) async {
    final hasContent = params.content?.trim().isNotEmpty ?? false;
    final hasMedia = params.media.isNotEmpty;

    if (!hasContent && !hasMedia) {
      return Left(EmptyFailure());
    }

    if (!await _networkInfo.checkIsConnected) {
      return Left(CacheFailure());
    }

    try {
      final model = CreatePostModel(
        content: params.content,
        media: params.media,
      );
      final result = await _postRemoteDatasource.createPost(model);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> update(UpdatePostParams params) async {
    if (!params.hasContentField && !params.hasMediaField) {
      return Left(EmptyFailure());
    }

    if (!await _networkInfo.checkIsConnected) {
      return Left(CacheFailure());
    }

    try {
      final model = UpdatePostModel(
        postId: params.postId,
        content: params.content,
        media: params.media,
        hasContentField: params.hasContentField,
        hasMediaField: params.hasMediaField,
      );

      final result = await _postRemoteDatasource.updatePost(model);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> delete(DeletePostParams params) async {
    if (params.postId.trim().isEmpty) {
      return Left(EmptyFailure());
    }

    if (!await _networkInfo.checkIsConnected) {
      return Left(CacheFailure());
    }

    try {
      final result = await _postRemoteDatasource.deletePost(params.postId);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PostEntity>> toggleLike(String postId) async {
    if (postId.trim().isEmpty) {
      return Left(EmptyFailure());
    }

    if (!await _networkInfo.checkIsConnected) {
      return Left(CacheFailure());
    }

    try {
      final result = await _postRemoteDatasource.toggleLike(postId);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PostCommentEntity>> createComment(
    String postId,
    String content, {
    String? parentCommentId,
  }) async {
    if (postId.trim().isEmpty || content.trim().isEmpty) {
      return Left(EmptyFailure());
    }

    if (!await _networkInfo.checkIsConnected) {
      return Left(CacheFailure());
    }

    try {
      final result = await _postRemoteDatasource.createComment(
        postId,
        CreateCommentModel(content: content, parentCommentId: parentCommentId),
      );
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PostCommentsEntity>> getComments(String postId) async {
    if (postId.trim().isEmpty) {
      return Left(EmptyFailure());
    }

    if (!await _networkInfo.checkIsConnected) {
      return Left(CacheFailure());
    }

    try {
      final result = await _postRemoteDatasource.getComments(postId);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
