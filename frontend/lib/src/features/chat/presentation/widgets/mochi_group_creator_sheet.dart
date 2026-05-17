import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/theme/app_colors.dart';

import '../../../../core/utils/url_normalizer.dart';
import '../../../friend/presentation/pages/friend_picker_bottom_sheet.dart';
import '../../domain/entities/chat_entity.dart';
import 'mochi_dm_search_input.dart';

/// Bottom sheet cho phép đặt tên nhóm và chọn thành viên từ danh sách bạn bè.
class MochiGroupCreatorSheet extends StatefulWidget {
  const MochiGroupCreatorSheet({
    super.key,
    required this.friendsFuture,
    required this.onCreate,
  });

  final Future<List<FriendPickerUser>> friendsFuture;
  final Future<ChatEntity?> Function({
    required String name,
    required List<String> memberIds,
  }) onCreate;

  @override
  State<MochiGroupCreatorSheet> createState() => _MochiGroupCreatorSheetState();
}

class _MochiGroupCreatorSheetState extends State<MochiGroupCreatorSheet> {
  final TextEditingController _nameController = TextEditingController();
  final Set<String> _selectedIds = <String>{};
  String _query = '';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<FriendPickerUser> _filterFriends(List<FriendPickerUser> friends) {
    final keyword = _query.trim().toLowerCase();
    if (keyword.isEmpty) {
      return friends;
    }
    return friends.where((friend) {
      final source = '${friend.name} ${friend.username}'.toLowerCase();
      return source.contains(keyword);
    }).toList();
  }

  Future<void> _handleCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedIds.isEmpty || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);
    final chatEntity = await widget.onCreate(
      name: name,
      memberIds: _selectedIds.toList(),
    );
    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);
    if (chatEntity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.createGroupFailed)),
      );
      return;
    }

    Navigator.of(context).pop(chatEntity);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final createEnabled =
        _nameController.text.trim().isNotEmpty && _selectedIds.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: colors.appBarForeground,
                  ),
                  Expanded(
                    child: Text(
                      context.l10n.createGroupChatTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.appBarForeground,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: createEnabled ? _handleCreate : null,
                    child: _isSubmitting
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.appBarForeground,
                            ),
                          )
                        : Text(
                            context.l10n.createGroupAction,
                            style: TextStyle(
                              color: colors.appBarForeground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // ── Group name + search ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: context.l10n.groupNameHint,
                      hintStyle: TextStyle(color: colors.textSecondary),
                      filled: true,
                      fillColor: colors.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.accent),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  MochiDmSearchInput(
                    onChanged: (value) =>
                        setState(() => _query = value.trim()),
                    padding: EdgeInsets.zero,
                    fillColor: colors.inputFill,
                    hintColor: colors.textSecondary,
                    iconColor: colors.accent,
                    focusedBorderColor: colors.inputBorder,
                    borderRadius: 14,
                    hintText: context.l10n.searchMembersHint,
                    dense: true,
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: colors.subtleBorder),

            // ── Friends list ───────────────────────────────────────────────
            Expanded(
              child: FutureBuilder<List<FriendPickerUser>>(
                future: widget.friendsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(context.l10n.loadFriendsListFailed),
                    );
                  }

                  final friends = _filterFriends(
                    snapshot.data ?? const <FriendPickerUser>[],
                  );
                  if (friends.isEmpty) {
                    return Center(child: Text(context.l10n.noFriendsFoundInChat));
                  }

                  return ListView.separated(
                    itemCount: friends.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: colors.subtleBorder),
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      final avatar = friend.avatarUrl.normalizeClientUrl();
                      final hasAvatar = avatar.isNotEmpty;
                      final isSelected = _selectedIds.contains(friend.id);

                      return CheckboxListTile(
                        value: isSelected,
                        activeColor: colors.accent,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedIds.add(friend.id);
                            } else {
                              _selectedIds.remove(friend.id);
                            }
                          });
                        },
                        title: Text(
                          friend.name,
                          style: TextStyle(color: colors.textPrimary),
                        ),
                        subtitle: friend.username.isEmpty
                            ? null
                            : Text(
                                '@${friend.username}',
                                style: TextStyle(color: colors.textSecondary),
                              ),
                        secondary: CircleAvatar(
                          backgroundColor: colors.avatarPlaceholder,
                          backgroundImage:
                              hasAvatar ? NetworkImage(avatar) : null,
                          child: hasAvatar
                              ? null
                              : Text(
                                  friend.name.isNotEmpty
                                      ? friend.name[0].toUpperCase()
                                      : '?',
                                ),
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
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
