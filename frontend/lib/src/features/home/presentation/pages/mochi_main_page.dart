import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../routes/app_route_path.dart';
import '../../../../widgets/feature_page_scaffold.dart';
import '../../domain/entities/home_entity.dart';
import '../bloc/home/home_bloc.dart';
import '../widgets/home_widgets.dart';

class MochiMainPage extends StatelessWidget {
  const MochiMainPage({super.key});

  static const List<HomePostItem> _fallbackPosts = [
    HomePostItem(
      author: 'An Nguyen',
      minutesAgo: 8,
      content: 'Loading feed from API...',
      likes: 132,
      comments: 16,
    ),
    HomePostItem(
      author: 'Binh Tran',
      minutesAgo: 21,
      content: 'Switch to your backend data and remove fallback entries.',
      likes: 88,
      comments: 9,
    ),
  ];

  static List<HomeStoryItem> _buildStories(List<HomeEntity> items) {
    final people = items.where((item) => item.kind == 'person').toList();
    if (people.isEmpty) {
      return const [
        HomeStoryItem(name: 'Your story', hasUnread: false),
        HomeStoryItem(name: 'An', hasUnread: true),
      ];
    }

    final stories = people.take(8).map((item) {
      return HomeStoryItem(name: item.title, hasUnread: item.isOnline);
    }).toList();

    return [
      const HomeStoryItem(name: 'Your story', hasUnread: false),
      ...stories,
    ].take(9).toList();
  }

  static List<HomePostItem> _buildPosts(List<HomeEntity> items) {
    final posts = items.where((item) => item.kind == 'post').map((item) {
      return HomePostItem(
        author: item.title,
        minutesAgo: item.minutesAgo,
        content: item.subtitle,
        likes: item.likesCount,
        comments: item.commentsCount,
        mediaUrl: item.mediaUrl,
      );
    }).toList();

    if (posts.isEmpty) {
      return _fallbackPosts;
    }

    return posts;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => getIt<HomeBloc>()..add(const HomeFetchedEvent()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final loadedItems = state is HomeSuccessState
              ? state.items
              : const <HomeEntity>[];
          final stories = _buildStories(loadedItems);
          final posts = _buildPosts(loadedItems);

          return FeaturePageScaffold(
            title: 'Mochi Main',
            bodyPadding: EdgeInsets.zero,
            isLoading: state is HomeInitialState || state is HomeLoadingState,
            errorTitle: state is HomeFailureState ? 'Cannot load feed' : null,
            errorMessage: state is HomeFailureState ? state.message : null,
            onRetry: () =>
                context.read<HomeBloc>().add(const HomeFetchedEvent()),
            actions: [
              IconButton(
                onPressed: () => context.pushNamed(AppRoutes.homeSearch.name),
                icon: const Icon(Icons.search),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
              ),
            ],
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              children: [
                const HomeComposerCard(),
                const SizedBox(height: 12),
                HomeStoriesStrip(items: stories),
                const SizedBox(height: 16),
                const HomeSectionHeader(title: 'Feed', actionText: 'See all'),
                const SizedBox(height: 8),
                ...posts.map((post) => HomeFeedPostCard(item: post)),
              ],
            ),
          );
        },
      ),
    );
  }
}
