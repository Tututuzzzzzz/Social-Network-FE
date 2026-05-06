import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../routes/app_route_path.dart';
import '../../../friend/presentation/pages/friend_picker_bottom_sheet.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/usecases/create_direct_conversation_usecase.dart';
import '../../domain/usecases/usecase_params.dart';
import '../bloc/chat/chat_bloc.dart';
import '../widgets/mochi_dm_conversation_item.dart';
import '../widgets/mochi_dm_pending_header.dart';
import '../widgets/mochi_dm_search_input.dart';
import '../widgets/mochi_dm_section_header.dart';
import '../widgets/mochi_dm_status_view.dart';
import '../widgets/mochi_dm_styles.dart';
import '../widgets/mochi_dm_top_bar.dart';

class MochiDirectMessagesPage extends StatefulWidget {
  const MochiDirectMessagesPage({super.key});

  @override
  State<MochiDirectMessagesPage> createState() =>
      _MochiDirectMessagesPageState();
}

class _MochiDirectMessagesPageState extends State<MochiDirectMessagesPage> {
  static const String _username = 'Tin Nhắn';

  String _query = '';
  bool _showPendingThreads = true;

  Future<void> _createConversationAndOpen(
    FriendPickerUser friend,
    BuildContext blocContext,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final chatBloc = blocContext.read<ChatBloc>();
    final router = GoRouter.of(blocContext);

    ChatEntity? chatEntity;

    try {
      if (getIt.isRegistered<CreateDirectConversationUseCase>()) {
        final useCase = getIt<CreateDirectConversationUseCase>();
        final result = await useCase(
          CreateDirectConversationParams(recipientId: friend.id),
        );

        result.fold(
          (_) {
            chatEntity = null;
          },
          (chat) {
            chatEntity = chat;
          },
        );
      } else {
        chatEntity = await _createConversationFallback(friend);
      }
    } catch (_) {
      chatEntity = await _createConversationFallback(friend);
    }

    if (!mounted || !blocContext.mounted) {
      return;
    }

    if (chatEntity == null || chatEntity!.id.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Khong tao duoc cuoc tro chuyen')),
      );
      return;
    }

    chatBloc.add(const ChatFetchedEvent());
    await router.pushNamed(
      AppRoutes.chatMochiChatRoom.name,
      pathParameters: {'threadId': chatEntity!.id},
      extra: chatEntity,
    );
  }

  Future<ChatEntity?> _createConversationFallback(
    FriendPickerUser friend,
  ) async {
    final apiHelper = getIt<ApiHelper>();
    final result = await apiHelper.execute(
      method: Method.post,
      url: ApiConstants.conversations,
      data: {'type': 'direct', 'recipientId': friend.id},
    );

    final raw = result['conversation'];
    if (raw is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(raw);
    final id = (map['_id'] ?? map['id'] ?? '').toString();
    if (id.isEmpty) {
      return null;
    }

    return ChatEntity(
      id: id,
      recipientId: friend.id,
      senderName: friend.name,
      messagePreview: 'Start chatting...',
      timeLabel: 'now',
      isGroup: false,
      fullConversation: '${friend.name}: Start chatting...',
    );
  }

  Future<void> _openFriendsPicker(BuildContext blocContext) async {
    final selectedFriend = await showFriendPickerBottomSheet(context);
    if (!mounted || !blocContext.mounted || selectedFriend == null) {
      return;
    }
    await _createConversationAndOpen(selectedFriend, blocContext);
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
    return value.isEmpty ? 'Conversation' : value;
  }

  String _displayPreview(ChatEntity item) {
    final value = item.messagePreview.trim();
    return value.isEmpty ? 'Start chatting...' : value;
  }

  String _displayTimeLabel(ChatEntity item) {
    final value = item.timeLabel.trim();
    if (value.isEmpty) {
      return '.now';
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
          title: const Text('Xoa doan chat'),
          content: Text('Ban co muon xoa doan chat voi $name khong?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Huy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xoa'),
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
          final activeThreads = visibleThreads
              .where((item) => !item.isHidden)
              .toList();
          final pendingThreads = visibleThreads
              .where((item) => item.isHidden)
              .toList();
          final isInitialLoading =
              (state is ChatInitialState || state is ChatLoadingState) &&
              loadedThreads.isEmpty;

          Widget listContent;
          if (state is ChatFailureState && loadedThreads.isEmpty) {
            listContent = MochiDmStatusView(
              icon: Icons.error_outline,
              title: 'Khong the tai tin nhan',
              subtitle: state.message,
              onRetry: () =>
                  context.read<ChatBloc>().add(const ChatFetchedEvent()),
            );
          } else if (isInitialLoading) {
            listContent = const Center(child: CircularProgressIndicator());
          } else if (activeThreads.isEmpty && pendingThreads.isEmpty) {
            listContent = const MochiDmStatusView(
              icon: Icons.search_off_outlined,
              title: 'Khong tim thay doan chat',
              subtitle: 'Thu tim voi tu khoa khac.',
            );
          } else {
            listContent = ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                ...List.generate(activeThreads.length, (index) {
                  final item = activeThreads[index];
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
                }),
                if (activeThreads.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: Text(
                      'Khong co tin nhan trong hop chinh.',
                      style: TextStyle(
                        fontSize: 13,
                        color: MochiDmStyles.searchHint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (pendingThreads.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  MochiDmPendingHeader(
                    showPending: _showPendingThreads,
                    onToggle: () => setState(
                      () => _showPendingThreads = !_showPendingThreads,
                    ),
                  ),
                  if (_showPendingThreads)
                    ...List.generate(pendingThreads.length, (index) {
                      final item = pendingThreads[index];
                      final name = _displayName(item);
                      return MochiDmConversationItem(
                        item: item,
                        index: activeThreads.length + index,
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
                    }),
                ],
              ],
            );
          }

          return Scaffold(
            backgroundColor: MochiDmStyles.pageBackground,
            body: SafeArea(
              child: Column(
                children: [
                  MochiDmTopBar(
                    username: _username,
                    onAddPressed: () => _openFriendsPicker(context),
                  ),
                  MochiDmSearchInput(
                    onChanged: (value) => setState(() => _query = value.trim()),
                  ),
                  MochiDmSectionHeader(
                    pendingCount: pendingThreads.length,
                    canTogglePending: pendingThreads.isNotEmpty,
                    onTogglePending: () => setState(
                      () => _showPendingThreads = !_showPendingThreads,
                    ),
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