import 'package:flutter/material.dart';

import '../../../../core/utils/url_normalizer.dart';
import '../../../friend/presentation/pages/friend_picker_bottom_sheet.dart';
import '../../domain/entities/chat_entity.dart';
import 'mochi_dm_search_input.dart';
import 'mochi_dm_styles.dart';

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
        const SnackBar(content: Text('Khong tao duoc nhom chat')),
      );
      return;
    }

    Navigator.of(context).pop(chatEntity);
  }

  @override
  Widget build(BuildContext context) {
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
              decoration: const BoxDecoration(
                color: MochiDmStyles.primaryGreen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: MochiDmStyles.topBarText,
                  ),
                  const Expanded(
                    child: Text(
                      'Tao nhom chat',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MochiDmStyles.topBarText,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: createEnabled ? _handleCreate : null,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Tao',
                            style: TextStyle(
                              color: Colors.white,
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
                      hintText: 'Ten nhom',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: Color(0xFFE2E6E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: MochiDmStyles.primaryGreen,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  MochiDmSearchInput(
                    onChanged: (value) =>
                        setState(() => _query = value.trim()),
                    padding: EdgeInsets.zero,
                    fillColor: MochiDmStyles.searchBackground,
                    hintColor: MochiDmStyles.searchHint,
                    iconColor: MochiDmStyles.searchIcon,
                    focusedBorderColor: MochiDmStyles.primaryGreenSoft,
                    borderRadius: 14,
                    hintText: 'Tim thanh vien',
                    dense: true,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Friends list ───────────────────────────────────────────────
            Expanded(
              child: FutureBuilder<List<FriendPickerUser>>(
                future: widget.friendsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Khong tai duoc danh sach ban be'),
                    );
                  }

                  final friends = _filterFriends(
                    snapshot.data ?? const <FriendPickerUser>[],
                  );
                  if (friends.isEmpty) {
                    return const Center(child: Text('Khong co ban be nao'));
                  }

                  return ListView.separated(
                    itemCount: friends.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      final avatar = friend.avatarUrl.normalizeClientUrl();
                      final hasAvatar = avatar.isNotEmpty;
                      final isSelected = _selectedIds.contains(friend.id);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedIds.add(friend.id);
                            } else {
                              _selectedIds.remove(friend.id);
                            }
                          });
                        },
                        title: Text(friend.name),
                        subtitle: friend.username.isEmpty
                            ? null
                            : Text('@${friend.username}'),
                        secondary: CircleAvatar(
                          backgroundColor: const Color(0xFFE8EBF4),
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
