import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/failure_converter.dart';
import '../../../friend/domain/usecases/accept_friend_request.dart';
import '../../../friend/domain/usecases/reject_friend_request.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_as_read_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationAsReadUseCase _markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase _markAllNotificationsAsReadUseCase;

  NotificationBloc(
    this._getNotificationsUseCase,
    this._markNotificationAsReadUseCase,
    this._markAllNotificationsAsReadUseCase,
  ) : super(const NotificationState()) {
    on<NotificationLoadRequested>(_onLoadRequested);
    on<NotificationLoadMoreRequested>(_onLoadMoreRequested);
    on<NotificationMarkAsReadRequested>(_onMarkAsReadRequested);
    on<NotificationMarkAllAsReadRequested>(_onMarkAllAsReadRequested);
    on<NotificationAcceptFriendRequestRequested>(_onAcceptFriendRequestRequested);
    on<NotificationRejectFriendRequestRequested>(_onRejectFriendRequestRequested);
  }

  Future<void> _onLoadRequested(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        unreadOnly: event.unreadOnly,
        clearError: true,
      ),
    );

    final result = await _getNotificationsUseCase.call(
      GetNotificationsParams(page: 1, limit: 20, unreadOnly: event.unreadOnly),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: mapFailureToMessage(failure),
          ),
        );
      },
      (data) {
        emit(
          state.copyWith(
            items: data.items,
            page: data.page,
            hasMore: data.hasMore,
            unreadCount: data.unreadCount,
            isLoading: false,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreRequested(
    NotificationLoadMoreRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearError: true));

    final nextPage = state.page + 1;
    final result = await _getNotificationsUseCase.call(
      GetNotificationsParams(
        page: nextPage,
        limit: 20,
        unreadOnly: state.unreadOnly,
      ),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoadingMore: false,
            errorMessage: mapFailureToMessage(failure),
          ),
        );
      },
      (data) {
        final merged = List<NotificationEntity>.from(state.items)
          ..addAll(data.items);

        emit(
          state.copyWith(
            items: merged,
            page: data.page,
            hasMore: data.hasMore,
            unreadCount: data.unreadCount,
            isLoadingMore: false,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onMarkAsReadRequested(
    NotificationMarkAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final target = state.items.where((item) => item.id == event.notificationId);
    if (target.isEmpty || target.first.isRead) {
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    final result = await _markNotificationAsReadUseCase.call(
      MarkNotificationAsReadParams(event.notificationId),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: mapFailureToMessage(failure),
          ),
        );
      },
      (_) {
        final updatedItems = state.items
            .map(
              (item) => item.id == event.notificationId
                  ? item.copyWith(isRead: true, readAt: DateTime.now())
                  : item,
            )
            .toList();

        final nextUnreadCount = state.unreadCount > 0
            ? state.unreadCount - 1
            : 0;

        emit(
          state.copyWith(
            items: updatedItems,
            unreadCount: nextUnreadCount,
            isSubmitting: false,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onMarkAllAsReadRequested(
    NotificationMarkAllAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.items.isEmpty || state.unreadCount == 0) {
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    final result = await _markAllNotificationsAsReadUseCase.call(NoParams());

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: mapFailureToMessage(failure),
          ),
        );
      },
      (_) {
        final now = DateTime.now();
        final updatedItems = state.items
            .map(
              (item) =>
                  item.isRead ? item : item.copyWith(isRead: true, readAt: now),
            )
            .toList();

        emit(
          state.copyWith(
            items: updatedItems,
            unreadCount: 0,
            isSubmitting: false,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onAcceptFriendRequestRequested(
    NotificationAcceptFriendRequestRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      final useCase = getIt<AcceptFriendRequest>();
      await useCase(event.requestId);

      if (!isClosed) {
        final updatedItems = state.items
            .where((item) => item.id != event.notificationId)
            .toList();

        emit(
          state.copyWith(
            items: updatedItems,
            isSubmitting: false,
            clearError: true,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _onRejectFriendRequestRequested(
    NotificationRejectFriendRequestRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      final useCase = getIt<RejectFriendRequest>();
      await useCase(event.requestId);

      if (!isClosed) {
        final updatedItems = state.items
            .where((item) => item.id != event.notificationId)
            .toList();

        emit(
          state.copyWith(
            items: updatedItems,
            isSubmitting: false,
            clearError: true,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }
}
