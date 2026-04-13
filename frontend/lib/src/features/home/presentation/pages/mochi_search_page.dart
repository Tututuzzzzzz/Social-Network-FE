import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../widgets/feature_page_scaffold.dart';
import '../../domain/entities/home_entity.dart';
import '../bloc/home/home_bloc.dart';
import '../widgets/home_widgets.dart';

class MochiSearchPage extends StatefulWidget {
  const MochiSearchPage({super.key});

  @override
  State<MochiSearchPage> createState() => _MochiSearchPageState();
}

class _MochiSearchPageState extends State<MochiSearchPage> {
  static const List<String> _tabs = ['People', 'Posts', 'Photos', 'Places'];

  int _selectedTab = 0;
  String _query = '';

  bool _matchesQuery(String source) {
    if (_query.isEmpty) {
      return true;
    }

    return source.toLowerCase().contains(_query.toLowerCase());
  }

  List<HomeUserResult> _buildPeople(List<HomeEntity> items) {
    final people = items
        .where((item) => item.kind == 'person')
        .where((item) {
          final text = '${item.title} ${item.handle} ${item.subtitle}';
          return _matchesQuery(text);
        })
        .map((item) {
          return HomeUserResult(
            name: item.title,
            handle: item.handle,
            mutualFriends: item.mutualFriends,
            isOnline: item.isOnline,
          );
        })
        .toList();

    if (_selectedTab == 0) {
      return people;
    }

    return people.take(2).toList();
  }

  bool _matchesDiscoveryTab(HomeEntity item) {
    if (_selectedTab == 0) {
      return true;
    }

    if (_selectedTab == 1) {
      return item.category == 'posts';
    }
    if (_selectedTab == 2) {
      return item.category == 'photos';
    }

    return item.category == 'places';
  }

  IconData _iconFromKey(String iconKey) {
    switch (iconKey) {
      case 'food':
        return Icons.ramen_dining_outlined;
      case 'route':
        return Icons.route_outlined;
      case 'music':
        return Icons.music_note_outlined;
      case 'design':
        return Icons.palette_outlined;
      case 'photo':
        return Icons.camera_alt_outlined;
      case 'coffee':
        return Icons.coffee_outlined;
      default:
        return Icons.explore_outlined;
    }
  }

  List<HomeDiscoveryItem> _buildDiscovery(List<HomeEntity> items) {
    return items
        .where((item) => item.kind == 'discover')
        .where(_matchesDiscoveryTab)
        .where((item) => _matchesQuery('${item.title} ${item.subtitle}'))
        .map((item) {
          return HomeDiscoveryItem(
            title: item.title,
            subtitle: item.subtitle,
            icon: _iconFromKey(item.iconKey),
          );
        })
        .toList();
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
          final people = _buildPeople(loadedItems);
          final discovery = _buildDiscovery(loadedItems);

          return FeaturePageScaffold(
            title: 'Mochi Search',
            isLoading: state is HomeInitialState || state is HomeLoadingState,
            isEmpty:
                state is HomeSuccessState &&
                people.isEmpty &&
                discovery.isEmpty,
            emptyTitle: 'No results found',
            emptyMessage: 'Try another keyword or switch the filter tab.',
            emptyIcon: Icons.search_off_outlined,
            errorTitle: state is HomeFailureState ? 'Cannot load search' : null,
            errorMessage: state is HomeFailureState ? state.message : null,
            onRetry: () =>
                context.read<HomeBloc>().add(const HomeFetchedEvent()),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border),
              ),
            ],
            body: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                HomeSearchInput(
                  onChanged: (value) => setState(() => _query = value.trim()),
                  onSubmitted: () {},
                ),
                const SizedBox(height: 12),
                HomeFilterTabs(
                  tabs: _tabs,
                  selectedIndex: _selectedTab,
                  onChanged: (value) => setState(() => _selectedTab = value),
                ),
                const SizedBox(height: 18),
                const HomeSectionHeader(title: 'People', actionText: 'See all'),
                const SizedBox(height: 8),
                ...people.map(
                  (item) => HomeUserResultTile(
                    item: item,
                    onTap: () {},
                    onTapFollow: () {},
                  ),
                ),
                const SizedBox(height: 16),
                const HomeSectionHeader(
                  title: 'Discover',
                  actionText: 'Explore',
                ),
                const SizedBox(height: 8),
                HomeDiscoveryGrid(items: discovery),
              ],
            ),
          );
        },
      ),
    );
  }
}
