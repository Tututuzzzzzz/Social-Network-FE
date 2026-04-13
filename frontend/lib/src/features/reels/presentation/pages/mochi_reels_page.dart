import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../widgets/feature_page_scaffold.dart';
import '../../domain/entities/reels_entity.dart';
import '../bloc/reels/reels_bloc.dart';

class MochiReelsPage extends StatelessWidget {
  const MochiReelsPage({super.key});

  String _formatTime(int minutesAgo) {
    if (minutesAgo < 1) {
      return 'now';
    }
    if (minutesAgo < 60) {
      return '${minutesAgo}m';
    }

    final hours = minutesAgo ~/ 60;
    if (hours < 24) {
      return '${hours}h';
    }

    return '${hours ~/ 24}d';
  }

  Widget _buildReelCard(BuildContext context, ReelsEntity item) {
    final caption = item.caption.isEmpty ? 'No caption' : item.caption;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 9 / 14,
        child: Stack(
          children: [
            Positioned.fill(
              child: item.mediaUrl.isEmpty
                  ? Container(
                      color: const Color(0xFFE8EEF5),
                      alignment: Alignment.center,
                      child: const Icon(Icons.ondemand_video, size: 42),
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
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 70,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.authorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 10,
              bottom: 14,
              child: Column(
                children: [
                  const Icon(Icons.favorite_border, color: Colors.white),
                  const SizedBox(height: 4),
                  Text(
                    '${item.likesCount}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Icon(Icons.chat_bubble_outline, color: Colors.white),
                  const SizedBox(height: 4),
                  Text(
                    '${item.commentsCount}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatTime(item.minutesAgo),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReelsBloc>(
      create: (_) => getIt<ReelsBloc>()..add(const ReelsFetchedEvent()),
      child: BlocBuilder<ReelsBloc, ReelsState>(
        builder: (context, state) {
          final reels = state is ReelsSuccessState
              ? state.items
              : const <ReelsEntity>[];

          return FeaturePageScaffold(
            title: 'Mochi Reels',
            isLoading: state is ReelsInitialState || state is ReelsLoadingState,
            isEmpty: state is ReelsSuccessState && reels.isEmpty,
            emptyTitle: 'No reels yet',
            emptyMessage: 'No short-form content from API at the moment.',
            emptyIcon: Icons.video_library_outlined,
            errorTitle: state is ReelsFailureState ? 'Cannot load reels' : null,
            errorMessage: state is ReelsFailureState ? state.message : null,
            onRetry: () =>
                context.read<ReelsBloc>().add(const ReelsFetchedEvent()),
            bodyPadding: EdgeInsets.zero,
            body: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              itemCount: reels.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildReelCard(context, reels[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
