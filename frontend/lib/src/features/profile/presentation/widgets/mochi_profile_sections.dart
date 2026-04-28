import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FacebookStyleTopBar(
                      profile: profile,
                      onOpenMenu: onOpenMenu,
                    ),
                    _FacebookStyleCoverAndAvatar(profile: profile),
                    const SizedBox(height: 60), // Space for overlapping avatar
                    _FacebookStyleInfoSection(profile: profile),
                    const SizedBox(height: 16),
                    _FacebookStyleActionButtons(
                      onEditProfile: onEditProfile,
                    ),
                    const SizedBox(height: 16),
                    const Divider(
                      height: 1,
                      thickness: 8,
                      color: Color(0xFFC9CCD1),
                    ),
                    const SizedBox(height: 16),
                    _FacebookStyleDetailsSection(profile: profile),
                    const SizedBox(height: 16),
                    const Divider(
                      height: 1,
                      thickness: 8,
                      color: Color(0xFFC9CCD1),
                    ),
                    const SizedBox(height: 16),
                    const _FacebookStylePhotosHeader(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              if (images.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 28, 16, 130),
                    child: Center(
                      child: Text(
                        'Chưa có ảnh',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF65676B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(
                    bottom: 130,
                    left: 16,
                    right: 16,
                  ),
                  sliver: SliverGrid.builder(
                    itemCount: images.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, index) {
                      final imageUrl = images[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
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
                                top: 6,
                                right: 6,
                                child: Icon(
                                  Icons.copy_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
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

class _FacebookStyleTopBar extends StatelessWidget {
  final ProfileEntity profile;
  final VoidCallback onOpenMenu;

  const _FacebookStyleTopBar({
    required this.profile,
    required this.onOpenMenu,
  });

  @override
  Widget build(BuildContext context) {
    final username = (profile.username ?? '').trim().isNotEmpty
        ? profile.username!.trim()
        : 'username';

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10, right: 12),
      child: Row(
        children: [
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 24),
              ],
            ),
          ),
          IconButton(
            onPressed: onOpenMenu,
            icon: SvgPicture.string(
              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-settings-icon lucide-settings"><path d="M9.671 4.136a2.34 2.34 0 0 1 4.659 0 2.34 2.34 0 0 0 3.319 1.915 2.34 2.34 0 0 1 2.33 4.033 2.34 2.34 0 0 0 0 3.831 2.34 2.34 0 0 1-2.33 4.033 2.34 2.34 0 0 0-3.319 1.915 2.34 2.34 0 0 1-4.659 0 2.34 2.34 0 0 0-3.32-1.915 2.34 2.34 0 0 1-2.33-4.033 2.34 2.34 0 0 0 0-3.831A2.34 2.34 0 0 1 6.35 6.051a2.34 2.34 0 0 0 3.319-1.915"/><circle cx="12" cy="12" r="3"/></svg>',
              width: 26,
              height: 26,
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

class _FacebookStyleCoverAndAvatar extends StatelessWidget {
  final ProfileEntity profile;

  const _FacebookStyleCoverAndAvatar({required this.profile});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _normalizeClientMediaUrl(
      (profile.avatarUrl ?? '').trim(),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover Photo Placeholder
        Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFE4E6EB),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Stack(
            children: [
              // Optionally add a subtle gradient or camera icon here
              Positioned(
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, size: 20),
                ),
              ),
            ],
          ),
        ),
        // Overlapping Avatar
        Positioned(
          bottom: -60, // Overlap by 60px
          left: 16,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // White border around avatar
              border: Border.all(color: Colors.white, width: 4),
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
        ),
        // Mini Camera Icon on Avatar
        Positioned(
          bottom: -50,
          left: 116,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE4E6EB),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.camera_alt, size: 18),
          ),
        ),
      ],
    );
  }
}

class _FacebookStyleInfoSection extends StatelessWidget {
  final ProfileEntity profile;

  const _FacebookStyleInfoSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final displayName = (profile.displayName ?? '').trim().isNotEmpty
        ? profile.displayName!.trim()
        : 'Người dùng';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if ((profile.bio ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              profile.bio!.trim(),
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1C1E21),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FacebookStyleActionButtons extends StatelessWidget {
  final VoidCallback onEditProfile;

  const _FacebookStyleActionButtons({
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Blue "Add to Story" Button
          Expanded(
            child: Material(
              color: const Color(0xFF1877F2),
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                onTap: () {}, // UI Only
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 36,
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Thêm vào tin',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Grey "Edit Profile" Button
          Expanded(
            child: Material(
              color: const Color(0xFFE4E6EB),
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                onTap: onEditProfile,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 36,
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, color: Colors.black, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Chỉnh sửa trang...',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FacebookStyleDetailsSection extends StatelessWidget {
  final ProfileEntity profile;

  const _FacebookStyleDetailsSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.rss_feed,
            text: 'Có ${profile.friendsCount} người theo dõi',
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.people_alt,
            text: 'Đang theo dõi ${profile.friendsCount} người',
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.grid_on,
            text: '${profile.postsCount} bài viết',
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF8C939D), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

class _FacebookStylePhotosHeader extends StatelessWidget {
  const _FacebookStylePhotosHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Ảnh',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Xem tất cả ảnh',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
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
      child: Center(
        child: Icon(Icons.person, size: 70, color: Colors.white),
      ),
    );
  }
}
