import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../configs/injector/injector_conf.dart';
import 'package:frontend/src/core/theme/app_colors.dart';
import '../../../../core/utils/url_normalizer.dart';
import '../../../../routes/app_route_path.dart';
import '../../domain/entities/friend.dart';
import '../../domain/usecases/get_friends.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  late Future<List<Friend>> _friendsFuture;

  @override
  void initState() {
    super.initState();
    _friendsFuture = _loadFriends();
  }

  Future<List<Friend>> _loadFriends() {
    return getIt<GetFriends>().call();
  }

  Future<void> _refreshFriends() async {
    setState(() {
      _friendsFuture = _loadFriends();
    });

    try {
      await _friendsFuture;
    } catch (_) {
      // The FutureBuilder below owns the visible error state.
    }
  }

  void _openFriendProfile(Friend friend) {
    final friendId = friend.id.trim();
    if (friendId.isEmpty) {
      return;
    }

    context.pushNamed(
      AppRoutes.otherProfile.name,
      pathParameters: {'userId': friendId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.scaffold,
      appBar: AppBar(
        backgroundColor: colors.appBar,
        foregroundColor: colors.appBarForeground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Bạn bè',
          style: TextStyle(
            color: colors.appBarForeground,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: FutureBuilder<List<Friend>>(
        future: _friendsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _FriendsLoadingList();
          }

          if (snapshot.hasError) {
            return _FriendsStatusList(
              icon: Icons.error_outline_rounded,
              title: 'Không tải được bạn bè',
              message: 'Vui lòng kiểm tra kết nối và thử lại.',
              actionLabel: 'Thử lại',
              onAction: _refreshFriends,
              onRefresh: _refreshFriends,
            );
          }

          final friends = snapshot.data ?? const <Friend>[];
          if (friends.isEmpty) {
            return _FriendsStatusList(
              icon: Icons.group_off_rounded,
              title: 'Chưa có bạn bè',
              message: 'Danh sách bạn bè của bạn sẽ hiển thị ở đây.',
              onRefresh: _refreshFriends,
            );
          }

          return RefreshIndicator(
            color: colors.accent,
            onRefresh: _refreshFriends,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: friends.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final friend = friends[index];
                return _FriendListTile(
                  friend: friend,
                  onTap: () => _openFriendProfile(friend),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FriendListTile extends StatelessWidget {
  const _FriendListTile({required this.friend, required this.onTap});

  final Friend friend;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final name = _resolveName(friend);

    return Material(
      color: colors.sheetSurface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.subtleBorder),
          ),
          child: Row(
            children: [
              _FriendAvatar(friend: friend, displayName: name),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _resolveName(Friend friend) {
    final name = friend.name.trim();
    return name.isNotEmpty ? name : 'Người dùng';
  }
}

class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({required this.friend, required this.displayName});

  final Friend friend;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final avatarUrl = friend.avatarUrl?.normalizeClientUrl() ?? '';

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: colors.avatarPlaceholder,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarUrl.isEmpty
          ? _FriendAvatarFallback(displayName: displayName)
          : Image.network(
              avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return _FriendAvatarFallback(displayName: displayName);
              },
            ),
    );
  }
}

class _FriendAvatarFallback extends StatelessWidget {
  const _FriendAvatarFallback({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final initial = displayName.trim().isEmpty
        ? '?'
        : displayName.trim().characters.first.toUpperCase();

    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: colors.accent,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FriendsLoadingList extends StatelessWidget {
  const _FriendsLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => const _FriendLoadingTile(),
    );
  }
}

class _FriendLoadingTile extends StatelessWidget {
  const _FriendLoadingTile();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.sheetSurface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.subtleBorder),
      ),
      child: Row(
        children: [
          const _LoadingBlock(width: 52, height: 52, isCircle: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _LoadingBlock(width: 150, height: 14),
                SizedBox(height: 8),
                _LoadingBlock(width: 92, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock({
    required this.width,
    required this.height,
    this.isCircle = false,
  });

  final double width;
  final double height;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.inputFill,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(999),
      ),
    );
  }
}

class _FriendsStatusList extends StatelessWidget {
  const _FriendsStatusList({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRefresh,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    return RefreshIndicator(
      color: colors.accent,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: colors.chipFollowBg.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: colors.accent, size: 30),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: colors.textSecondary,
                                height: 1.35,
                              ),
                        ),
                        if (actionLabel != null && onAction != null) ...[
                          const SizedBox(height: 18),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.accent,
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                            onPressed: () => onAction!(),
                            child: Text(actionLabel!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
