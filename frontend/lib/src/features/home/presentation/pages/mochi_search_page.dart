import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../domain/entities/home_entity.dart';
import '../bloc/home/home_bloc.dart';
import '../widgets/home_widgets.dart';
import '../../../../core/l10n/l10n.dart';

class MochiSearchPage extends StatefulWidget {
  const MochiSearchPage({super.key});

  @override
  State<MochiSearchPage> createState() => _MochiSearchPageState();
}

class _MochiSearchPageState extends State<MochiSearchPage> {
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

  Widget _buildSearchResults(
    BuildContext context,
    List<HomeUserResult> people,
    List<HomeDiscoveryItem> discovery,
  ) {
    final tabs = [
      context.l10n.searchPeople,
      context.l10n.searchPosts,
      context.l10n.searchPhotos,
      context.l10n.searchPlaces,
    ];

    if (people.isEmpty && discovery.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: Text(
            context.l10n.searchNoResults,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      children: [
        HomeFilterTabs(
          tabs: tabs,
          selectedIndex: _selectedTab,
          onChanged: (value) => setState(() => _selectedTab = value),
        ),
        const SizedBox(height: 18),
        if (people.isNotEmpty) ...[
          HomeSectionHeader(
            title: context.l10n.searchPeople,
            actionText: context.l10n.searchSeeAll,
          ),
          const SizedBox(height: 8),
          ...people.map(
            (item) => HomeUserResultTile(
              item: item,
              onTap: () {},
              onTapFollow: () {},
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (discovery.isNotEmpty) ...[
          const HomeSectionHeader(title: 'Discover', actionText: 'Explore'),
          const SizedBox(height: 8),
          HomeDiscoveryGrid(items: discovery),
        ],
      ],
    );
  }

  Widget _buildExploreGrid(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey.shade300,
          child: Icon(Icons.image, color: Colors.grey.shade400, size: 32),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => getIt<HomeBloc>()..add(const HomeFetchedEvent()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final loadedItems =
              state is HomeSuccessState ? state.items : const <HomeEntity>[];
          final people = _buildPeople(loadedItems);
          final discovery = _buildDiscovery(loadedItems);

          final isSearching = _query.isNotEmpty;
          final isLoading =
              state is HomeInitialState || state is HomeLoadingState;

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: HomeSearchInput(
                      onChanged: (value) =>
                          setState(() => _query = value.trim()),
                      onSubmitted: () {},
                    ),
                  ),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : isSearching
                            ? _buildSearchResults(context, people, discovery)
                            : _buildExploreGrid(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
