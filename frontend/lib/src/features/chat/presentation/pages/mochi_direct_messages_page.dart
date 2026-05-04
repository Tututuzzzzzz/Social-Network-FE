import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../../../routes/app_route_path.dart';
import '../../domain/entities/chat_entity.dart';
import '../bloc/chat/chat_bloc.dart';

class MochiDirectMessagesPage extends StatefulWidget {
  const MochiDirectMessagesPage({super.key});

  @override
  State<MochiDirectMessagesPage> createState() =>
      _MochiDirectMessagesPageState();
}

class _MochiDirectMessagesPageState extends State<MochiDirectMessagesPage> {
  static const List<Color> _avatarColors = [
    Color(0xFFE8EBF4),
    Color(0xFFEDE4EC),
    Color(0xFFE5F0E7),
    Color(0xFFF2EAD9),
    Color(0xFFE7E6F6),
  ];

  String _query = '';
  bool _showPendingThreads = true;




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

  Widget _buildTopBar(BuildContext blocContext) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              blocContext.l10n.titleChat,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: SizedBox(
        height: 35,
        child: TextField(
          onChanged: (value) => setState(() => _query = value.trim()),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: context.l10n.searchLabel,
            hintStyle: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF8E8E93), size: 20),
            filled: true,
            fillColor: const Color(0xFFEBEBEB),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(int pendingCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          const Text(
            'Tin nhắn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: pendingCount == 0
                ? null
                : () => setState(
                    () => _showPendingThreads = !_showPendingThreads,
                  ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6E9BFF),
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Tin nhắn đang chờ',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          const Text(
            'Tin nhắn đang chờ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111113),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () =>
                setState(() => _showPendingThreads = !_showPendingThreads),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6E9BFF),
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _showPendingThreads ? 'Thu gọn' : 'Mở rộng',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDeleteDialog(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa đoạn chat'),
          content: Text('Bạn có muốn xóa đoạn chat với $name không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                shape: const StadiumBorder(),
              ),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                shape: const StadiumBorder(),
              ),
              child: const Text('Xóa'),
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

  Widget _buildConversationItem(
    BuildContext context,
    ChatEntity item,
    int index,
  ) {
    final name = _displayName(item);

    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.72,
        children: [
          SlidableAction(
            onPressed: (_) {
              context.read<ChatBloc>().add(ChatThreadPinToggledEvent(item.id));
            },
            backgroundColor: const Color(0xFF4B8EFF),
            foregroundColor: Colors.white,
            icon: item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: item.isPinned ? 'Bỏ ghim' : 'Ghim',
          ),
          SlidableAction(
            onPressed: (_) {
              context.read<ChatBloc>().add(
                ChatThreadHiddenChangedEvent(item.id, isHidden: !item.isHidden),
              );
            },
            backgroundColor: const Color(0xFF8E8E93),
            foregroundColor: Colors.white,
            icon: item.isHidden
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            label: item.isHidden ? 'Hiện' : 'Ẩn',
          ),
          SlidableAction(
            onPressed: (_) async {
              final chatBloc = context.read<ChatBloc>();
              final confirmed = await _confirmDeleteDialog(name);
              if (!mounted || !confirmed) {
                return;
              }
              chatBloc.add(ChatThreadDeletedEvent(item.id));
            },
            backgroundColor: const Color(0xFFE84545),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Xóa',
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openChatThread(item, context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  context.pushNamed(
                    AppRoutes.otherProfile.name,
                    pathParameters: {'userId': item.recipientId},
                  );
                },
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: _avatarColors[index % _avatarColors.length],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initial(name),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2A2B2F),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              height: 1,
                            ),
                          ),
                        ),
                        if (item.isOnline)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1EC85D),
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (item.isPinned)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.push_pin,
                              size: 14,
                              color: Color(0xFF4B8EFF),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            _displayPreview(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8E8E93),
                              fontWeight: FontWeight.w400,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _displayTimeLabel(item),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8E8E93),
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusView({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: const Color(0xFF6E6F73)),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2A2B2F),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6E6F73)),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton(onPressed: onRetry, child: const Text('Thu lai')),
            ],
          ],
        ),
      ),
    );
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
            listContent = _buildStatusView(
              icon: Icons.error_outline,
              title: 'Khong the tai tin nhan',
              subtitle: state.message,
              onRetry: () =>
                  context.read<ChatBloc>().add(const ChatFetchedEvent()),
            );
          } else if (isInitialLoading) {
            listContent = const Center(child: CircularProgressIndicator());
          } else if (activeThreads.isEmpty && pendingThreads.isEmpty) {
            listContent = _buildStatusView(
              icon: Icons.search_off_outlined,
              title: 'Khong tim thay doan chat',
              subtitle: 'Thu tim voi tu khoa khac.',
            );
          } else {
            listContent = ListView(
              padding: EdgeInsets.zero,
              children: [
                ...List.generate(activeThreads.length, (index) {
                  return _buildConversationItem(
                    context,
                    activeThreads[index],
                    index,
                  );
                }),
                if (activeThreads.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: Text(
                      'Không có tin nhắn trong hộp chính.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (pendingThreads.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildPendingHeader(),
                  if (_showPendingThreads)
                    ...List.generate(pendingThreads.length, (index) {
                      return _buildConversationItem(
                        context,
                        pendingThreads[index],
                        activeThreads.length + index,
                      );
                    }),
                ],
                const SizedBox(height: 100),
              ],
            );
          }

          return Material(
            color: Colors.transparent,
            child: Column(
              children: [
                _buildTopBar(context),
                _buildSearchInput(),
                _buildSectionHeader(pendingThreads.length),
                if (state is ChatLoadingState && loadedThreads.isNotEmpty)
                  const LinearProgressIndicator(minHeight: 2),
                Expanded(child: listContent),
              ],
            ),
          );
        },
      ),
    );
  }
}