import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/api/api_helper.dart';
import '../../../friend/presentation/pages/friend_picker_bottom_sheet.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/usecases/create_direct_conversation_usecase.dart';
import '../../domain/usecases/usecase_params.dart';
import '../widgets/mochi_dm_styles.dart';
import '../widgets/mochi_group_creator_sheet.dart';
import '../widgets/mochi_new_conv_friend_tile.dart';
import '../widgets/mochi_new_conv_group_row.dart';
import '../widgets/mochi_new_conv_helpers.dart';
import '../widgets/mochi_new_conv_top_bar.dart';

class MochiNewConversationPage extends StatefulWidget {
  const MochiNewConversationPage({super.key});

  @override
  State<MochiNewConversationPage> createState() =>
      _MochiNewConversationPageState();
}

class _MochiNewConversationPageState extends State<MochiNewConversationPage> {
  String _query = '';
  late final Future<List<FriendPickerUser>> _friendsFuture;

  @override
  void initState() {
    super.initState();
    _friendsFuture = fetchFriendsForPicker();
  }

  // ── Create direct conversation ────────────────────────────────────────────

  Future<void> _createConversationAndClose(FriendPickerUser friend) async {
    final messenger = ScaffoldMessenger.of(context);
    ChatEntity? chatEntity;

    try {
      if (getIt.isRegistered<CreateDirectConversationUseCase>()) {
        final useCase = getIt<CreateDirectConversationUseCase>();
        final result = await useCase(
          CreateDirectConversationParams(recipientId: friend.id),
        );

        result.fold(
          (_) => chatEntity = null,
          (chat) => chatEntity = chat,
        );
      } else {
        chatEntity = await createDirectConversationFallback(
          getIt<ApiHelper>(),
          friend.id,
          friend.name,
          friend.avatarUrl,
        );
      }
    } catch (_) {
      chatEntity = await createDirectConversationFallback(
        getIt<ApiHelper>(),
        friend.id,
        friend.name,
        friend.avatarUrl,
      );
    }

    if (!mounted) return;

    if (chatEntity == null || chatEntity!.id.trim().isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.createConversationFailed)),
      );
      return;
    }

    final normalized = chatEntity!.avatarUrl.trim().isEmpty
        ? chatEntity!.copyWith(avatarUrl: friend.avatarUrl)
        : chatEntity!;

    Navigator.of(context).pop(normalized);
  }

  // ── Open group creator sheet ──────────────────────────────────────────────

  Future<void> _openGroupCreator() async {
    final result = await showModalBottomSheet<ChatEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MochiDmStyles.pageBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => MochiGroupCreatorSheet(
        friendsFuture: _friendsFuture,
        onCreate: ({required String name, required List<String> memberIds}) =>
            createGroupConversation(
          getIt<ApiHelper>(),
          name: name,
          memberIds: memberIds,
        ),
      ),
    );

    if (!mounted) return;
    if (result is ChatEntity) {
      Navigator.of(context).pop(result);
    }
  }

  // ── Filter ────────────────────────────────────────────────────────────────

  List<FriendPickerUser> _filterFriends(List<FriendPickerUser> friends) {
    final keyword = _query.trim().toLowerCase();
    if (keyword.isEmpty) return friends;

    return friends.where((friend) {
      final source = '${friend.name} ${friend.username}'.toLowerCase();
      return source.contains(keyword);
    }).toList();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MochiDmStyles.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            MochiNewConvTopBar(
              onSearchChanged: (value) =>
                  setState(() => _query = value.trim()),
            ),
            MochiNewConvGroupRow(onCreateGroup: _openGroupCreator),
            Expanded(
              child: FutureBuilder<List<FriendPickerUser>>(
                future: _friendsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(context.l10n.loadFriendsFailed),
                    );
                  }

                  final friends = _filterFriends(
                    snapshot.data ?? const <FriendPickerUser>[],
                  );
                  if (friends.isEmpty) {
                    return Center(child: Text(context.l10n.noFriendsFound));
                  }

                  return ListView.separated(
                    itemCount: friends.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return MochiNewConvFriendTile(
                        friend: friend,
                        index: index,
                        onTap: () => _createConversationAndClose(friend),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
