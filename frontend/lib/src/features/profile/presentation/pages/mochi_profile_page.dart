import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../widgets/feature_page_scaffold.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile/profile_bloc.dart';

class MochiProfilePage extends StatelessWidget {
  const MochiProfilePage({super.key});

  String _compactCount(int value) {
    if (value < 1000) {
      return '$value';
    }
    if (value < 1000000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }

  Widget _buildAvatar(ProfileEntity profile) {
    final displayText = profile.displayName.isNotEmpty
        ? profile.displayName
        : profile.username;
    final initial = displayText.isNotEmpty
        ? displayText.substring(0, 1).toUpperCase()
        : 'U';

    if (profile.avatarUrl.isEmpty) {
      return CircleAvatar(
        radius: 38,
        child: Text(
          initial,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }

    return CircleAvatar(
      radius: 38,
      backgroundImage: NetworkImage(profile.avatarUrl),
      onBackgroundImageError: (error, stackTrace) {},
    );
  }

  Widget _buildHeader(BuildContext context, ProfileEntity profile) {
    final displayName = profile.displayName.isNotEmpty
        ? profile.displayName
        : profile.username;
    final username = profile.username.isNotEmpty ? '@${profile.username}' : '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(profile),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (username.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            username,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[700]),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (profile.bio.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(profile.bio, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Posts',
                    value: _compactCount(profile.postsCount),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'Friends',
                    value: _compactCount(profile.friendsCount),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostGrid(List<ProfilePostPreview> posts) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final item = posts[index];

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: item.mediaUrl.isEmpty
                    ? Container(
                        color: const Color(0xFFE8EEF5),
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined),
                      )
                    : Image.network(
                        item.mediaUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFE8EEF5),
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
              ),
              Positioned(
                left: 6,
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${item.likesCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) => getIt<ProfileBloc>()..add(const ProfileFetchedEvent()),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final profile = state is ProfileSuccessState && state.items.isNotEmpty
              ? state.items.first
              : null;

          return FeaturePageScaffold(
            title: 'Mochi Profile',
            isLoading:
                state is ProfileInitialState || state is ProfileLoadingState,
            isEmpty: state is ProfileSuccessState && profile == null,
            emptyTitle: 'Profile is empty',
            emptyMessage: 'No profile data available from API.',
            emptyIcon: Icons.person_outline,
            errorTitle: state is ProfileFailureState
                ? 'Cannot load profile'
                : null,
            errorMessage: state is ProfileFailureState ? state.message : null,
            onRetry: () =>
                context.read<ProfileBloc>().add(const ProfileFetchedEvent()),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
            body: profile == null
                ? const SizedBox.shrink()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                    children: [
                      _buildHeader(context, profile),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            'Posts',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          Text(
                            '${profile.posts.length} shown',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (profile.posts.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7FB),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'No posts published yet.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      else
                        _buildPostGrid(profile.posts),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
