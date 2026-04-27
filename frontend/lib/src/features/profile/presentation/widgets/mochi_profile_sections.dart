import 'package:flutter/material.dart';

import '../../../../core/api/api_constants.dart';
import '../../../../core/utils/url_normalizer.dart';
import '../../domain/entities/profile_entity.dart';

class MochiProfileBody extends StatelessWidget {
  final ProfileEntity profile;
  final List<String> images;
  final Set<String> overlayImageUrls;
  final VoidCallback onEditProfile;
  final VoidCallback onOpenMenu;
  final Future<void> Function() onRefresh;

  const MochiProfileBody({
    super.key,
    required this.profile,
    required this.images,
    required this.overlayImageUrls,
    required this.onEditProfile,
    required this.onOpenMenu,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MochiProfileTopBar(
                        profile: profile,
                        onOpenMenu: onOpenMenu,
                      ),
                      const SizedBox(height: 14),
                      _MochiProfileHeader(profile: profile),
                      const SizedBox(height: 12),
                      if ((profile.displayName ?? '').trim().isNotEmpty)
                        Text(
                          profile.displayName!.trim(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF171718),
                          ),
                        ),
                      if ((profile.displayName ?? '').trim().isNotEmpty)
                        const SizedBox(height: 6),
                      Text(
                        (profile.bio ?? '').trim().isNotEmpty
                            ? profile.bio!.trim()
                            : 'No bio yet',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF141414),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _MochiActionButtons(onEditProfile: onEditProfile),
                      const SizedBox(height: 16),
                      const _MochiHighlights(),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE4E4E7),
                ),
              ),
              const SliverToBoxAdapter(child: _MochiProfileTabBar()),
              if (images.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 28, 16, 130),
                    child: Center(
                      child: Text(
                        'Chưa có ảnh bài đăng',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7F8085),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 130),
                  sliver: SliverGrid.builder(
                    itemCount: images.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, index) {
                      final imageUrl = images[index];
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey.shade300),
                          ),
                          if (overlayImageUrls.contains(imageUrl))
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(
                                Icons.copy_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MochiProfileErrorView extends StatelessWidget {
  final Future<void> Function() onRetry;

  const MochiProfileErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Không tải được profile'),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => onRetry(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _MochiProfileTopBar extends StatelessWidget {
  final ProfileEntity profile;
  final VoidCallback onOpenMenu;

  const _MochiProfileTopBar({required this.profile, required this.onOpenMenu});

  @override
  Widget build(BuildContext context) {
    final username = (profile.username ?? '').trim().isNotEmpty
        ? profile.username!.trim()
        : 'username';

    return Row(
      children: [
        const Icon(Icons.lock, size: 14, color: Color(0xFF161616)),
        const SizedBox(width: 6),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121212),
                  ),
                ),
              ),
              const SizedBox(width: 3),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onOpenMenu,
          icon: const Icon(Icons.menu_rounded, size: 28),
          tooltip: 'Tùy chọn',
        ),
      ],
    );
  }
}

class _MochiProfileHeader extends StatelessWidget {
  final ProfileEntity profile;

  const _MochiProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final followers = profile.friendsCount;
    final following = profile.friendsCount;
    final avatarUrl = _normalizeClientMediaUrl(
      (profile.avatarUrl ?? '').trim(),
    );

    return Row(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFCFCFD1), width: 2),
          ),
          child: ClipOval(
            child: avatarUrl.isNotEmpty
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const _AvatarPlaceholder(),
                  )
                : const _AvatarPlaceholder(),
          ),
        ),
        const SizedBox(width: 22),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatColumn(value: '${profile.postsCount}', label: 'bài viết'),
              _StatColumn(value: '$followers', label: 'người theo dõi'),
              _StatColumn(value: '$following', label: 'đang theo dõi'),
            ],
          ),
        ),
      ],
    );
  }
}

String _normalizeClientMediaUrl(String input) {
  final raw = input.trim();
  if (raw.isEmpty) {
    return '';
  }

  final apiUri = Uri.parse(ApiConstants.baseUrl);
  var normalized = raw;

  if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
    final origin =
        '${apiUri.scheme}://${apiUri.host}${apiUri.hasPort ? ':${apiUri.port}' : ''}';
    normalized = raw.startsWith('/') ? '$origin$raw' : '$origin/$raw';
  }

  return normalizeClientNetworkUrl(normalized);
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFE5E5E6),
      child: Center(child: Icon(Icons.person, size: 48, color: Colors.white)),
    );
  }
}

class _MochiActionButtons extends StatelessWidget {
  final VoidCallback onEditProfile;

  const _MochiActionButtons({required this.onEditProfile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionPillButton(label: 'Chỉnh sửa', onTap: onEditProfile),
        ),
        SizedBox(width: 8),
        const Expanded(
          child: _ActionPillButton(label: 'Chia sẻ trang cá nhân'),
        ),
      ],
    );
  }
}

class _MochiHighlights extends StatelessWidget {
  const _MochiHighlights();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 106,
      child: Row(
        children: [_HighlightItem(icon: Icons.add, label: 'Mới')],
      ),
    );
  }
}

class _MochiProfileTabBar extends StatelessWidget {
  const _MochiProfileTabBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Row(
          children: [
            Expanded(
              child: Center(child: Icon(Icons.grid_on_rounded, size: 28)),
            ),
            Expanded(
              child: Center(
                child: Icon(
                  Icons.account_box_outlined,
                  size: 28,
                  color: Color(0xFF9FA0A4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(height: 2, color: const Color(0xFF1E1E20)),
            ),
            const Expanded(child: SizedBox(height: 2)),
          ],
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111112),
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Color(0xFF2A2A2D)),
        ),
      ],
    );
  }
}

class _ActionPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _ActionPillButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8E8EA),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 44,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101010),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HighlightItem extends StatelessWidget {
  final IconData? icon;
  final String label;

  const _HighlightItem({this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 74,
          height: 74,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFCFCFD2)),
          ),
          child: ClipOval(
            child: Container(
              color: const Color(0xFFF4F4F5),
              child: Icon(icon ?? Icons.add, size: 36),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
