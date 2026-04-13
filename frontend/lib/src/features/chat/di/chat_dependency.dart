import '../../../configs/injector/injector_conf.dart';
import '../../../core/api/api_helper.dart';
import '../data/datasources/chat_local_datasource.dart';
import '../data/datasources/chat_remote_datasource.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../domain/usecases/fetch_chat_items_usecase.dart';
import '../presentation/bloc/chat/chat_bloc.dart';

class ChatDependency {
  ChatDependency._();

  static void init() {
    if (!getIt.isRegistered<ChatBloc>()) {
      getIt.registerFactory(() => ChatBloc(getIt<FetchChatItemsUseCase>()));
    }

    if (!getIt.isRegistered<FetchChatItemsUseCase>()) {
      getIt.registerLazySingleton(
        () => FetchChatItemsUseCase(getIt<ChatRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<ChatRepositoryImpl>()) {
      getIt.registerLazySingleton(
        () => ChatRepositoryImpl(
          getIt<ChatRemoteDataSourceImpl>(),
          getIt<ChatLocalDataSourceImpl>(),
        ),
      );
    }

    if (!getIt.isRegistered<ChatRemoteDataSourceImpl>()) {
      getIt.registerLazySingleton(
        () => ChatRemoteDataSourceImpl(getIt<ApiHelper>()),
      );
    }

    if (!getIt.isRegistered<ChatLocalDataSourceImpl>()) {
      getIt.registerLazySingleton(() => ChatLocalDataSourceImpl());
    }
  }
}
