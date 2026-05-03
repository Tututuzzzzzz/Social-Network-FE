import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/utils/url_normalizer.dart';
import '../../../../routes/app_route_path.dart';
import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/profile_entity.dart';

class MochiProfileBody extends StatelessWidget {
  final ProfileEntity profile;
  final List<String> images;
  final Set<String> overlayImageUrls;
  final bool isOtherUser;
  final VoidCallback onEditProfile;
  final VoidCallback? onFollow;
  final VoidCallback? onMessage;
  final VoidCallback onOpenMenu;
  final Future<void> Function() onRefresh;

  const MochiProfileBody({
    super.key,
    required this.profile,
    required this.images,
    required this.overlayImageUrls,
    this.isOtherUser = false,
    required this.onEditProfile,
    this.onFollow,
    this.onMessage,
    required this.onOpenMenu,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _MochiProfileHeader(
            profile: profile,
            onOpenMenu: onOpenMenu,
            isOtherUser: isOtherUser,
          ),
          _MochiProfileInfo(profile: profile),
          _MochiProfileActions(
            onEditProfile: onEditProfile,
            onFollow: onFollow,
            onMessage: onMessage,
            isOtherUser: isOtherUser,
          ),
          const SizedBox(height: 16),
          _MochiProfileStats(profile: profile),
          const Divider(height: 32),
          _MochiProfilePhotosGrid(
            images: images,
            overlayImageUrls: overlayImageUrls,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class MochiProfileErrorView extends StatelessWidget {
  final VoidCallback onRetry;

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

class _MochiProfileHeader extends StatelessWidget {
  final ProfileEntity profile;
  final VoidCallback onOpenMenu;
  final bool isOtherUser;

  const _MochiProfileHeader({
    required this.profile,
    required this.onOpenMenu,
    required this.isOtherUser,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _normalizeClientMediaUrl(profile.avatarUrl);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (isOtherUser)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
          CircleAvatar(
            radius: 40,
            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 40) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName ?? profile.username ?? 'Mochi User',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('@${profile.username ?? ''}'),
              ],
            ),
          ),
          if (!isOtherUser)
            IconButton(
              onPressed: onOpenMenu,
              icon: const Icon(Icons.settings),
            ),
        ],
      ),
    );
  }
}

class _MochiProfileInfo extends StatelessWidget {
  final ProfileEntity profile;

  const _MochiProfileInfo({required this.profile});

  @override
  Widget build(BuildContext context) {
    if ((profile.bio ?? '').isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(profile.bio!),
    );
  }
}

class _MochiProfileActions extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback? onFollow;
  final VoidCallback? onMessage;
  final bool isOtherUser;

  const _MochiProfileActions({
    required this.onEditProfile,
    this.onFollow,
    this.onMessage,
    required this.isOtherUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isOtherUser ? onFollow : onEditProfile,
              child: Text(
                isOtherUser
                    ? context.l10n.followAction
                    : context.l10n.editProfileTitle,
              ),
            ),
          ),
          if (isOtherUser) ...[
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: onMessage,
                child: Text(context.l10n.messagesTitle),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MochiProfileStats extends StatelessWidget {
  final ProfileEntity profile;

  const _MochiProfileStats({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStat(context.l10n.postsLabel, profile.postsCount),
        _buildStat(context.l10n.friends, profile.friendsCount),
      ],
    );
  }

  Widget _buildStat(String label, int count) {
    return Column(
      children: [
        Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}

class _MochiProfilePhotosGrid extends StatelessWidget {
  final List<String> images;
  final Set<String> overlayImageUrls;

  const _MochiProfilePhotosGrid({
    required this.images,
    required this.overlayImageUrls,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const Center(child: Text('Chưa có ảnh nào'));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(images[index], fit: BoxFit.cover),
            if (overlayImageUrls.contains(images[index]))
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.copy, color: Colors.white, size: 16),
              ),
          ],
        );
      },
    );
  }
}

String _normalizeClientMediaUrl(String? url) {
  final raw = (url ?? '').trim();
  if (raw.isEmpty) return '';
  if (raw.startsWith('http')) return normalizeClientNetworkUrl(raw);
  final apiUri = Uri.parse(ApiConstants.baseUrl);
  final origin = '${apiUri.scheme}://${apiUri.host}${apiUri.hasPort ? ':${apiUri.port}' : ''}';
  final full = raw.startsWith('/') ? '$origin$raw' : '$origin/$raw';
  return normalizeClientNetworkUrl(full);
}
