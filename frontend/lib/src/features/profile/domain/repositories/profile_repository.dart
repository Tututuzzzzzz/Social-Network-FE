import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../usecases/usecase_params.dart';
import '../../../post/domain/entities/post_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile(ProfileParams params);
  Future<Either<Failure, void>> updateProfile(UpdateProfileParams params);
  Future<Either<Failure, void>> updateAvatar(UpdateAvatarParams params);
  Future<Either<Failure, List<PostEntity>>> getUserPosts(
    GetUserPostsParams params,
  );
}
