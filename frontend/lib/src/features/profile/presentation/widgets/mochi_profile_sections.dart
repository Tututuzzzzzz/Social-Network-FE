import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/api/api_constants.dart';
import '../../../../core/utils/url_normalizer.dart';
import '../../domain/entities/profile_entity.dart';

class MochiProfileBody extends StatelessWidget {
  final ProfileEntity profile;
  final List<String> images;
  final Set<String> overlayImageUrls;
  final bool isOtherUser;
  final VoidCallback onEditProfile;
  final VoidCallback onOpenMenu;
  final Future<void> Function() onRefresh;

  const MochiProfileBody({
    super.key,
    required this.profile,
    required this.images,
    required this.overlayImageUrls,
    this.isOtherUser = false,
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
                    _MochiStyleTopBar(
                      profile: profile,
                      onOpenMenu: onOpenMenu,
                      isOtherUser: isOtherUser,
                    ),
                    _MochiStyleCoverAndAvatar(profile: profile),
                    const SizedBox(height: 60), // Space for overlapping avatar
                    _MochiStyleInfoSection(profile: profile),
                    const SizedBox(height: 16),
                    _MochiStyleActionButtons(
                      onEditProfile: onEditProfile,
                      isOtherUser: isOtherUser,
                    ),
                    const SizedBox(height: 16),
                    const Divider(
                      height: 1,
                      thickness: 8,
                      color: Color(0xFFC9CCD1),
                    ),
                    const SizedBox(height: 16),
                    _MochiStyleDetailsSection(profile: profile),
                    const SizedBox(height: 16),
                    const Divider(
                      height: 1,
                      thickness: 8,
                      color: Color(0xFFC9CCD1),
                    ),
                    const SizedBox(height: 16),
                    const _MochiStylePhotosHeader(),
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

class _MochiStyleTopBar extends StatelessWidget {
  final ProfileEntity profile;
  final VoidCallback onOpenMenu;
  final bool isOtherUser;

  const _MochiStyleTopBar({
    required this.profile,
    required this.onOpenMenu,
    required this.isOtherUser,
  });

  @override
  Widget build(BuildContext context) {
    final username = (profile.username ?? '').trim().isNotEmpty
        ? profile.username!.trim()
        : 'username';

    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 10, bottom: 10, right: 12),
      child: Row(
        children: [
          if (isOtherUser)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          if (!isOtherUser) const SizedBox(width: 8),
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
                if (!isOtherUser) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 24),
                ],
              ],
            ),
          ),
          if (!isOtherUser)
            IconButton(
              onPressed: onOpenMenu,
              icon: SvgPicture.string(
                '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-settings-icon lucide-settings"><path d="M9.671 4.136a2.34 2.34 0 0 1 4.659 0 2.34 2.34 0 0 0 3.319 1.915 2.34 2.34 0 0 1 2.33 4.033 2.34 2.34 0 0 0 0 3.831 2.34 2.34 0 0 1-2.33 4.033 2.34 2.34 0 0 0-3.319 1.915 2.34 2.34 0 0 1-4.659 0 2.34 2.34 0 0 0-3.32-1.915 2.34 2.34 0 0 1-2.33-4.033 2.34 2.34 0 0 0 0-3.831A2.34 2.34 0 0 1 6.35 6.051a2.34 2.34 0 0 0 3.319-1.915"/><circle cx="12" cy="12" r="3"/></svg>',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          if (isOtherUser)
            IconButton(
              onPressed: () {}, // Search user's posts UI
              icon: const Icon(Icons.search, color: Colors.black, size: 28),
            ),
        ],
      ),
    );
  }
}

class _MochiStyleCoverAndAvatar extends StatelessWidget {
  final ProfileEntity profile;

  const _MochiStyleCoverAndAvatar({required this.profile});

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

class _MochiStyleInfoSection extends StatelessWidget {
  final ProfileEntity profile;

  const _MochiStyleInfoSection({required this.profile});

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

class _MochiStyleActionButtons extends StatelessWidget {
  final VoidCallback onEditProfile;
  final bool isOtherUser;

  const _MochiStyleActionButtons({
    required this.onEditProfile,
    required this.isOtherUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Blue Primary Button: "Add to Story" or "Add Friend"
          Expanded(
            child: Material(
              color: const Color(0xFF1877F2),
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: () {}, // UI Only
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: 35,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isOtherUser ? Icons.person_add : Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOtherUser ? 'Thêm bạn bè' : 'Thêm vào tin',
                        style: const TextStyle(
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
          // Grey Secondary Button: "Edit Profile" or "Message"
          Expanded(
            child: Material(
              color: const Color(0xFFE4E6EB),
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: isOtherUser ? () {} : onEditProfile,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: 35,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.string(
                        isOtherUser
                            ? '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-send-icon lucide-send"><path d="M14.536 21.686a.5.5 0 0 0 .937-.024l6.5-19a.496.496 0 0 0-.635-.635l-19 6.5a.5.5 0 0 0-.024.937l7.93 3.18a2 2 0 0 1 1.112 1.11z"/><path d="m21.854 2.147-10.94 10.939"/></svg>'
                            : '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-edit-3"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>',
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOtherUser ? 'Nhắn tin' : 'Chỉnh sửa...',
                        style: const TextStyle(
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
          if (isOtherUser) ...[
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFFE4E6EB),
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 44,
                  height: 35,
                  alignment: Alignment.center,
                  child: const Icon(Icons.more_horiz, color: Colors.black),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MochiStyleDetailsSection extends StatelessWidget {
  final ProfileEntity profile;

  const _MochiStyleDetailsSection({required this.profile});

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

class _MochiStylePhotosHeader extends StatelessWidget {
  const _MochiStylePhotosHeader();

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
