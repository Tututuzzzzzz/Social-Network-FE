import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_route_path.dart';
import '../../domain/entities/chat_entity.dart';
import '../bloc/chat/chat_bloc.dart';
import '../widgets/mochi_dm_conversation_item.dart';
import '../widgets/mochi_dm_status_view.dart';
import '../widgets/mochi_dm_tab_switcher.dart';
import '../widgets/mochi_dm_top_bar.dart';
import 'package:frontend/src/core/l10n/l10n.dart';

class MochiDirectMessagesPage extends StatefulWidget {
  const MochiDirectMessagesPage({super.key});

  @override
  State<MochiDirectMessagesPage> createState() =>
      _MochiDirectMessagesPageState();
}

class _MochiDirectMessagesPageState extends State<MochiDirectMessagesPage> {
  String _query = '';
  int _tabIndex = 0;

  Future<void> _openNewConversationPage(BuildContext blocContext) async {
    final result = await blocContext.pushNamed(
      AppRoutes.chatNewConversation.name,
    );

    if (!mounted || !blocContext.mounted) {
      return;
    }

    if (result is ChatEntity) {
      blocContext.read<ChatBloc>().add(const ChatFetchedEvent());
      await blocContext.pushNamed(
        AppRoutes.chatMochiChatRoom.name,
        pathParameters: {'threadId': result.id},
        extra: result,
      );
    }
  }

  Future<void> _handleBackPressed() async {
    final didPop = await Navigator.of(context).maybePop();
    if (!didPop && mounted) {
      context.go(AppRoutes.home.path);
    }
  }

  List<ChatEntity> _visibleThreads(List<ChatEntity> threads) {
    final keyword = _query.toLowerCase();
    if (keyword.isEmpty) {
      return threads;
    }

    return threads.where((item) {
      final source = '${item.senderName} ${item.messagePreview}'.toLowerCase();
      return source.contains(keyword);
    }).toList();
  }

  String _displayName(ChatEntity item) {
    final value = item.senderName.trim();
    return value.isEmpty ? context.l10n.conversationTitle : value;
  }

  String _displayPreview(ChatEntity item) {
    final value = item.messagePreview.trim();
    if (value.isEmpty) {
      return context.l10n.startChatting;
    }

    if (value == '[Attachment]' || value == '[attachment]') {
      return context.l10n.attachmentLabel;
    }

    return value;
  }

  String _displayTimeLabel(ChatEntity item) {
    final value = item.timeLabel.trim();
    if (value.isEmpty || value == 'now' || value == context.l10n.timeNow) {
      return '.${context.l10n.timeNow}';
    }

    return value.startsWith('.') ? value : '.$value';
  }

  String _initial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return '?';
    }

    return trimmed.substring(0, 1).toUpperCase();
  }

  Future<bool> _confirmDeleteDialog(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.deleteChatTitle),
          content: Text(context.l10n.deleteChatConfirm(name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _openChatThread(
    ChatEntity item,
    BuildContext blocContext,
  ) async {
    final chatBloc = blocContext.read<ChatBloc>();
    chatBloc.add(ChatThreadUnreadClearedEvent(item.id));
    final result = await blocContext.pushNamed(
      AppRoutes.chatMochiChatRoom.name,
      pathParameters: {'threadId': item.id},
      extra: item,
    );

    if (!mounted || !blocContext.mounted) {
      return;
    }

    if (result is ChatEntity) {
      chatBloc.add(ChatThreadPreviewUpdatedEvent(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatBloc>(
      create: (_) => getIt<ChatBloc>()..add(const ChatFetchedEvent()),
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final loadedThreads = state is ChatSuccessState
              ? state.items
              : const <ChatEntity>[];
          final visibleThreads = _visibleThreads(loadedThreads);
          final groupThreads = visibleThreads
              .where((item) => item.isGroup)
              .toList();
          final displayThreads = _tabIndex == 0 ? visibleThreads : groupThreads;
          final isInitialLoading =
              (state is ChatInitialState || state is ChatLoadingState) &&
              loadedThreads.isEmpty;
          final colors = AppColors.of(context);

          Widget listContent;
          if (state is ChatFailureState && loadedThreads.isEmpty) {
            listContent = MochiDmStatusView(
              icon: Icons.error_outline,
              title: context.l10n.loadMessagesFailed,
              subtitle: state.message,
              onRetry: () =>
                  context.read<ChatBloc>().add(const ChatFetchedEvent()),
            );
          } else if (isInitialLoading) {
            listContent = const Center(child: CircularProgressIndicator());
          } else if (visibleThreads.isEmpty) {
            listContent = MochiDmStatusView(
              icon: Icons.search_off_outlined,
              title: context.l10n.noChatFound,
              subtitle: context.l10n.searchAnotherKeyword,
            );
          } else {
            listContent = ListView.separated(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: displayThreads.length,
              itemBuilder: (context, index) {
                final item = displayThreads[index];
                final name = _displayName(item);
                return MochiDmConversationItem(
                  item: item,
                  index: index,
                  name: name,
                  preview: _displayPreview(item),
                  timeLabel: _displayTimeLabel(item),
                  initial: _initial(name),
                  onTap: () => _openChatThread(item, context),
                  onPinToggle: () => context.read<ChatBloc>().add(
                    ChatThreadPinToggledEvent(item.id),
                  ),
                  onHiddenToggle: () => context.read<ChatBloc>().add(
                    ChatThreadHiddenChangedEvent(
                      item.id,
                      isHidden: !item.isHidden,
                    ),
                  ),
                  onDelete: () async {
                    final chatBloc = context.read<ChatBloc>();
                    final confirmed = await _confirmDeleteDialog(name);
                    if (!mounted || !confirmed) {
                      return;
                    }
                    chatBloc.add(ChatThreadDeletedEvent(item.id));
                  },
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  height: 1,
                  thickness: 0.6,
                  color: colors.subtleBorder,
                );
              },
            );
          }

          return Scaffold(
            backgroundColor: colors.scaffold,
            body: SafeArea(
              child: Column(
                children: [
                  MochiDmTopBar(
                    onSearchChanged: (value) =>
                        setState(() => _query = value.trim()),
                    onEditPressed: () => _openNewConversationPage(context),
                    onBackPressed: _handleBackPressed,
                  ),
                  MochiDmTabSwitcher(
                    currentIndex: _tabIndex,
                    onChanged: (value) => setState(() => _tabIndex = value),
                  ),
                  if (state is ChatLoadingState && loadedThreads.isNotEmpty)
                    const LinearProgressIndicator(minHeight: 2),
                  Expanded(child: listContent),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
