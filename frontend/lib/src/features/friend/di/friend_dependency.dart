import '../../../configs/injector/injector_conf.dart';
import '../../../core/api/api_helper.dart';
import '../data/datasources/friend_remote_data_source.dart';
import '../data/repositories/friend_repository_impl.dart';
import '../domain/usecases/get_friend_requests.dart';
import '../domain/usecases/accept_friend_request.dart';
import '../domain/usecases/reject_friend_request.dart';
import '../presentation/bloc/friend_requests_bloc.dart';

class FriendDependency {
  FriendDependency._();

  static void init() {
    if (!getIt.isRegistered<FriendRequestsBloc>()) {
      getIt.registerFactory(
        () => FriendRequestsBloc(repository: getIt<FriendRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<GetFriendRequests>()) {
      getIt.registerLazySingleton(
        () => GetFriendRequests(getIt<FriendRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<AcceptFriendRequest>()) {
      getIt.registerLazySingleton(
        () => AcceptFriendRequest(getIt<FriendRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<RejectFriendRequest>()) {
      getIt.registerLazySingleton(
        () => RejectFriendRequest(getIt<FriendRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<FriendRepositoryImpl>()) {
      getIt.registerLazySingleton(
        () => FriendRepositoryImpl(
          remoteDataSource: getIt<FriendRemoteDataSourceImpl>(),
        ),
      );
    }

    if (!getIt.isRegistered<FriendRemoteDataSourceImpl>()) {
      getIt.registerLazySingleton(
        () => FriendRemoteDataSourceImpl(getIt<ApiHelper>()),
      );
    }
  }
}
