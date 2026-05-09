import '../../../configs/injector/injector_conf.dart';
import '../../../core/cache/hive_local_storage.dart';
import '../../../core/network/network_checker.dart';
import '../../../core/api/api_helper.dart';
import '../../chat/domain/usecases/create_direct_conversation_usecase.dart';
import '../../friend/domain/usecases/get_all_friend_ids.dart';
import '../../friend/domain/usecases/send_friend_request.dart';
import '../../post/domain/usecases/toggle_like_post_usecase.dart';
import '../data/datasources/profile_local_datasource.dart';
import '../data/datasources/profile_remote_datasource.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/usecases/get_profile_usecase.dart';
import '../domain/usecases/get_user_posts_usecase.dart';
import '../domain/usecases/update_avatar_usecase.dart';
import '../domain/usecases/update_profile_usecase.dart';
import '../presentation/bloc/profile/profile_bloc.dart';
import '../domain/repositories/profile_repository.dart';

class ProfileDependency {
  ProfileDependency._();

  static void init() {
    getIt.registerFactory(
      () => ProfileBloc(
        getIt<GetProfileUseCase>(),
        getIt<GetUserPostsUseCase>(),
        getIt<ToggleLikePostUseCase>(),
        getIt<UpdateProfileUseCase>(),
        getIt<GetAllFriendIds>(),
        getIt<SendFriendRequest>(),
        getIt<CreateDirectConversationUseCase>(),
      ),
    );

    getIt.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(getIt<ApiHelper>()),
    );

    getIt.registerLazySingleton<ProfileLocalDataSource>(
      () => ProfileLocalDataSourceImpl(getIt<HiveLocalStorage>()),
    );

    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        getIt<ProfileRemoteDataSource>(),
        getIt<ProfileLocalDataSource>(),
        getIt<NetworkInfo>(),
        getIt<HiveLocalStorage>(),
      ),
    );

    getIt.registerLazySingleton(
      () => GetProfileUseCase(getIt<ProfileRepository>()),
    );

    getIt.registerLazySingleton(
      () => GetUserPostsUseCase(getIt<ProfileRepository>()),
    );

    getIt.registerLazySingleton(
      () => UpdateProfileUseCase(getIt<ProfileRepository>()),
    );

    getIt.registerLazySingleton(
      () => UpdateAvatarUseCase(getIt<ProfileRepository>()),
    );
  }
}
