import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_entity.dart';

class NotificationState extends Equatable {
  final List<NotificationEntity> items;
  final int page;
  final bool hasMore;
  final bool unreadOnly;
  final int unreadCount;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSubmitting;
  final String? errorMessage;

  const NotificationState({
    this.items = const [],
    this.page = 1,
    this.hasMore = false,
    this.unreadOnly = false,
    this.unreadCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  NotificationState copyWith({
    List<NotificationEntity>? items,
    int? page,
    bool? hasMore,
    bool? unreadOnly,
    int? unreadCount,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      unreadOnly: unreadOnly ?? this.unreadOnly,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    items,
    page,
    hasMore,
    unreadOnly,
    unreadCount,
    isLoading,
    isLoadingMore,
    isSubmitting,
    errorMessage,
  ];
}
