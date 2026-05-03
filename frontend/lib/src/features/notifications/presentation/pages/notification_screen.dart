import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationBloc>().add(const NotificationLoadRequested());
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final threshold = _scrollController.position.maxScrollExtent - 120;
    if (_scrollController.position.pixels >= threshold) {
      context.read<NotificationBloc>().add(NotificationLoadMoreRequested());
    }
  }

  Future<void> _onRefresh() async {
    context.read<NotificationBloc>().add(
      const NotificationLoadRequested(refresh: true),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationBloc, NotificationState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        final message = state.errorMessage;
        if (message == null || message.isEmpty) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        final l10n = context.l10n;

        return Scaffold(
          backgroundColor: const Color(0xFFF3F3F3),
          appBar: AppBar(
            title: Text(l10n.notificationsTitle),
            actions: [
              TextButton(
                onPressed: state.unreadCount == 0 || state.isSubmitting
                    ? null
                    : () {
                        context.read<NotificationBloc>().add(
                          NotificationMarkAllAsReadRequested(),
                        );
                      },
                child: Text(l10n.markAllAsRead),
              ),
            ],
          ),
          body: state.isLoading && state.items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: state.items.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 180),
                            Center(
                              child: Text(
                                l10n.feedNotificationSoon,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount:
                              state.items.length + (state.hasMore ? 1 : 0),
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1, thickness: 0.6),
                          itemBuilder: (context, index) {
                            if (index >= state.items.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final item = state.items[index];
                            return _NotificationTile(
                              item: item,
                              showFriendRequestActions: item.isActionable,
                              isSubmitting: state.isSubmitting,
                              onTap: () {
                                if (!item.isRead) {
                                  context.read<NotificationBloc>().add(
                                    NotificationMarkAsReadRequested(item.id),
                                  );
                                }
                              },
                            );
                          },
                        ),
                ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity item;
  final bool showFriendRequestActions;
  final bool isSubmitting;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.item,
    required this.showFriendRequestActions,
    required this.isSubmitting,
    required this.onTap,
  });

  bool get _isFriendRequestNotification => item.type == 'FRIEND_REQUEST';

  @override
  Widget build(BuildContext context) {
    final createdAt = item.createdAt;
    final timeText = createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toLocal())
        : '';

    return Material(
      color: item.isRead ? Colors.white : const Color(0xFFF0F7FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: onTap,
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade300,
              child: item.actorName.trim().isNotEmpty
                  ? Text(
                      item.actorName.trim().characters.first.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    )
                  : const Icon(Icons.person_outline),
            ),
            title: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(item.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                if (timeText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    timeText,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ],
            ),
            trailing: item.isRead
                ? null
                : Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          if (_isFriendRequestNotification && showFriendRequestActions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            context.read<NotificationBloc>().add(
                              NotificationRejectFriendRequestRequested(
                                item.entityId!,
                                item.id,
                              ),
                            );
                          },
                    child: Text(context.l10n.rejectFriendRequest),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            context.read<NotificationBloc>().add(
                              NotificationAcceptFriendRequestRequested(
                                item.entityId!,
                                item.id,
                              ),
                            );
                          },
                    child: Text(context.l10n.acceptFriendRequest),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
