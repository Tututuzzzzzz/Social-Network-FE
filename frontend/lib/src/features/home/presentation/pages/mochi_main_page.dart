import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      authorId: 'fallback_1',
      author: 'An Nguyen',
      minutesAgo: 8,
      content: 'Loading feed from API...',
      likes: 132,
      comments: 16,
    ),
    HomePostItem(
      authorId: 'fallback_2',
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
        HomeStoryItem(id: 'me', name: 'Your story', hasUnread: false),
        HomeStoryItem(id: 'other_1', name: 'An', hasUnread: true),
      ];
    }

    final stories = people.take(8).map((item) {
      return HomeStoryItem(
        id: item.id,
        name: item.title,
        hasUnread: item.isOnline,
      );
    }).toList();

    return [
      const HomeStoryItem(id: 'me', name: 'Your story', hasUnread: false),
      ...stories,
    ].take(9).toList();
  }

  static List<HomePostItem> _buildPosts(List<HomeEntity> items) {
    final posts = items.where((item) => item.kind == 'post').map((item) {
      return HomePostItem(
        authorId: item.authorId,
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
            leading: GestureDetector(
              onTap: () => context.pushNamed(AppRoutes.profile.name),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: CircleAvatar(
                  radius: 14,
                  child: Text('Y'),
                ),
              ),
            ),
            titleWidget: Image.asset(
              'assets/images/logo1.jpg',
              height: 28,
              fit: BoxFit.contain,
            ),
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
                icon: SvgPicture.string(
                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-bell-icon lucide-bell"><path d="M10.268 21a2 2 0 0 0 3.464 0"/><path d="M3.262 15.326A1 1 0 0 0 4 17h16a1 1 0 0 0 .74-1.673C19.41 13.956 18 12.499 18 8A6 6 0 0 0 6 8c0 4.499-1.411 5.956-2.738 7.326"/></svg>',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                ),
              ),
            ],
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: SvgPicture.string(
                '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-square-plus-icon lucide-square-plus"><rect width="18" height="18" x="3" y="3" rx="2"/><path d="M8 12h8"/><path d="M12 8v8"/></svg>',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              children: [
                HomeComposerCard(
                  onTapAvatar: () =>
                      context.pushNamed(AppRoutes.profile.name),
                ),
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
