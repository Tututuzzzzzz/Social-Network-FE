import '../../../configs/injector/injector_conf.dart';
import '../../../core/api/api_helper.dart';
import '../../../core/cache/hive_local_storage.dart';
import '../data/datasources/message_local_datasource.dart';
import '../data/datasources/message_remote_datasource.dart';
import '../data/repositories/message_repository_impl.dart';
import '../domain/usecases/add_reaction_usecase.dart';
import '../domain/usecases/fetch_conversation_history_usecase.dart';
import '../domain/usecases/load_cached_conversation_history_usecase.dart';
import '../domain/usecases/mark_all_messages_as_read_usecase.dart';
import '../domain/usecases/mark_message_as_read_usecase.dart';
import '../domain/usecases/remove_reaction_usecase.dart';
import '../domain/usecases/save_cached_conversation_history_usecase.dart';
import '../domain/usecases/send_direct_media_usecase.dart';
import '../domain/usecases/send_direct_message_usecase.dart';
import '../domain/usecases/send_direct_text_usecase.dart';
import '../domain/usecases/send_group_media_usecase.dart';
import '../domain/usecases/send_group_message_usecase.dart';
import '../domain/usecases/send_group_text_usecase.dart';
import '../presentation/bloc/message_bloc.dart';

class MessageDependency {
  MessageDependency._();

  static void init() {
    if (!getIt.isRegistered<MessageBloc>()) {
      getIt.registerFactory(
        () => MessageBloc(
          getIt<SendDirectTextUseCase>(),
          getIt<FetchConversationHistoryUseCase>(),
          getIt<LoadCachedConversationHistoryUseCase>(),
          getIt<SaveCachedConversationHistoryUseCase>(),
        ),
      );
    }

    if (!getIt.isRegistered<SendDirectTextUseCase>()) {
      getIt.registerLazySingleton(
        () => SendDirectTextUseCase(getIt<MessageRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<SendDirectMediaUseCase>()) {
      getIt.registerLazySingleton(
        () => SendDirectMediaUseCase(getIt<MessageRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<SendGroupTextUseCase>()) {
      getIt.registerLazySingleton(
        () => SendGroupTextUseCase(getIt<MessageRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<SendGroupMediaUseCase>()) {
      getIt.registerLazySingleton(
        () => SendGroupMediaUseCase(getIt<MessageRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<SendDirectMessageUseCase>()) {
      getIt.registerLazySingleton(
        () => SendDirectMessageUseCase(getIt<MessageRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<SendGroupMessageUseCase>()) {
      getIt.registerLazySingleton(
        () => SendGroupMessageUseCase(getIt<MessageRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<AddReactionUseCase>()) {
      getIt.registerLazySingleton(
        () => AddReactionUseCase(getIt<MessageRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<RemoveReactionUseCase>()) {
      getIt.registerLazySingleton(
        () => RemoveReactionUseCase(getIt<MessageRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<MarkMessageAsReadUseCase>()) {
      getIt.registerLazySingleton(
        () => MarkMessageAsReadUseCase(getIt<MessageRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<MarkAllMessagesAsReadUseCase>()) {
      getIt.registerLazySingleton(
        () => MarkAllMessagesAsReadUseCase(getIt<MessageRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<FetchConversationHistoryUseCase>()) {
      getIt.registerLazySingleton(
        () => FetchConversationHistoryUseCase(getIt<MessageRepositoryImpl>()),
      );
    }

    if (!getIt.isRegistered<LoadCachedConversationHistoryUseCase>()) {
      getIt.registerLazySingleton(
        () => LoadCachedConversationHistoryUseCase(
          getIt<MessageRepositoryImpl>(),
        ),
      );
    }

    if (!getIt.isRegistered<SaveCachedConversationHistoryUseCase>()) {
      getIt.registerLazySingleton(
        () => SaveCachedConversationHistoryUseCase(
          getIt<MessageRepositoryImpl>(),
        ),
      );
    }

    if (!getIt.isRegistered<MessageRepositoryImpl>()) {
      getIt.registerLazySingleton(
        () => MessageRepositoryImpl(
          getIt<MessageRemoteDataSourceImpl>(),
          getIt<MessageLocalDataSourceImpl>(),
        ),
      );
    }

    if (!getIt.isRegistered<MessageRemoteDataSourceImpl>()) {
      getIt.registerLazySingleton(
        () => MessageRemoteDataSourceImpl(getIt<ApiHelper>()),
      );
    }

    if (!getIt.isRegistered<MessageLocalDataSourceImpl>()) {
      getIt.registerLazySingleton(
        () => MessageLocalDataSourceImpl(getIt<HiveLocalStorage>()),
      );
    }
  }
}
