import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../routes/app_route_path.dart';
import '../../../../widgets/feature_page_scaffold.dart';
import '../../domain/entities/chat_entity.dart';
import '../bloc/chat/chat_bloc.dart';

class MochiDirectMessagesPage extends StatefulWidget {
  const MochiDirectMessagesPage({super.key});

  @override
  State<MochiDirectMessagesPage> createState() =>
      _MochiDirectMessagesPageState();
}

class _MochiDirectMessagesPageState extends State<MochiDirectMessagesPage> {
  static const List<String> _filters = ['All', 'Unread', 'Groups'];

  int _selectedFilter = 0;
  String _query = '';

  bool _matchesQuery(ChatEntity item) {
    if (_query.isEmpty) {
      return true;
    }

    final source = '${item.senderName} ${item.messagePreview}';
    return source.toLowerCase().contains(_query.toLowerCase());
  }

  bool _matchesFilter(ChatEntity item) {
    if (_selectedFilter == 0) {
      return true;
    }
    if (_selectedFilter == 1) {
      return item.unreadCount > 0;
    }

    return item.isGroup;
  }

  List<_ActiveContact> _buildActiveContacts(List<ChatEntity> threads) {
    final unique = <String>{};
    final result = <_ActiveContact>[];

    for (final item in threads) {
      if (!unique.add(item.senderName)) {
        continue;
      }
      result.add(
        _ActiveContact(name: item.senderName, isOnline: item.isOnline),
      );
      if (result.length == 6) {
        break;
      }
    }

    return result;
  }

  List<ChatEntity> _visibleThreads(List<ChatEntity> threads) {
    return threads.where(_matchesFilter).where(_matchesQuery).toList();
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
          final activeContacts = _buildActiveContacts(loadedThreads);
          final visibleThreads = _visibleThreads(loadedThreads);

          return FeaturePageScaffold(
            title: 'Mochi Direct Messages',
            isLoading: state is ChatInitialState || state is ChatLoadingState,
            isEmpty: state is ChatSuccessState && visibleThreads.isEmpty,
            emptyTitle: 'No conversations found',
            emptyMessage: 'Try another filter or keyword.',
            emptyIcon: Icons.forum_outlined,
            errorTitle: state is ChatFailureState ? 'Cannot load chats' : null,
            errorMessage: state is ChatFailureState ? state.message : null,
            onRetry: () =>
                context.read<ChatBloc>().add(const ChatFetchedEvent()),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.call_outlined),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
            ],
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.edit_outlined),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              children: [
                TextField(
                  onChanged: (value) => setState(() => _query = value.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search conversations',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF3F6FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'Active now',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton(onPressed: () {}, child: const Text('See all')),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 84,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: activeContacts.length,
                    separatorBuilder: (_, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = activeContacts[index];
                      return SizedBox(
                        width: 64,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  child: Text(item.name.substring(0, 1)),
                                ),
                                if (item.isOnline)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 11,
                                      height: 11,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF26A65B),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < _filters.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            right: i == _filters.length - 1 ? 0 : 8,
                          ),
                          child: ChoiceChip(
                            label: Text(_filters[i]),
                            selected: i == _selectedFilter,
                            onSelected: (_) =>
                                setState(() => _selectedFilter = i),
                            showCheckmark: false,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...visibleThreads.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            child: Text(item.senderName.substring(0, 1)),
                          ),
                          if (item.isOnline)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF26A65B),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.4,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.senderName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: item.unreadCount > 0
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.timeLabel,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.messagePreview,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            if (item.isPinned)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.push_pin_outlined, size: 16),
                              ),
                            if (item.unreadCount > 0)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A9BFF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${item.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      onTap: () {
                        context.pushNamed(
                          AppRoutes.chatMochiChatRoom.name,
                          pathParameters: {'threadId': item.id},
                          extra: item,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActiveContact {
  final String name;
  final bool isOnline;

  const _ActiveContact({required this.name, required this.isOnline});
}
