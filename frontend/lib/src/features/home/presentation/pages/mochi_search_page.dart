import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../routes/app_route_path.dart';
import '../../domain/entities/home_entity.dart';
import '../bloc/home/home_bloc.dart';
import '../widgets/home_discovery_grid.dart';
import '../widgets/home_search_input.dart';
import '../widgets/home_section_header.dart';
import '../widgets/home_user_result_tile.dart';

class MochiSearchPage extends StatefulWidget {
  const MochiSearchPage({super.key});

  @override
  State<MochiSearchPage> createState() => _MochiSearchPageState();
}

class _MochiSearchPageState extends State<MochiSearchPage> {
  String _query = '';
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'Xu hướng',
    'Du lịch',
    'Ẩm thực',
    'Âm nhạc',
    'Phong cảnh',
    'Công nghệ',
  ];

  List<HomeEntity> _buildPeople(List<HomeEntity> items) {
    return items.where((item) => item.kind == 'person').toList();
  }

  List<HomeEntity> _buildDiscovery(List<HomeEntity> items) {
    return items.where((item) => item.kind == 'post').toList();
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<HomeEntity> people,
    List<HomeEntity> discovery,
  ) {
    final filteredPeople = people
        .where((p) =>
            (p.title.toLowerCase()).contains(_query.toLowerCase()) ||
            (p.handle.toLowerCase()).contains(_query.toLowerCase()))
        .toList();

    if (filteredPeople.isEmpty && discovery.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        if (filteredPeople.isNotEmpty) ...[
          const HomeSectionHeader(title: 'People', actionText: 'See all'),
          ...filteredPeople.map(
            (item) => HomeUserResultTile(
              item: HomeUserResult(
                id: item.id,
                name: item.title,
                handle: item.handle,
                mutualFriends: item.mutualFriends,
                isOnline: item.isOnline,
              ),
              onTap: () {
                context.pushNamed(
                  AppRoutes.otherProfile.name,
                  pathParameters: {'userId': item.id},
                );
              },
              onTapFollow: () {},
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (discovery.isNotEmpty) ...[
          const HomeSectionHeader(title: 'Discover', actionText: 'Explore'),
          const SizedBox(height: 8),
          HomeDiscoveryGrid(
            items: discovery
                .map((d) => HomeDiscoveryItem(
                      title: d.title,
                      subtitle: d.subtitle,
                      icon: Icons.explore_outlined,
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildExploreGrid(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Bubbles
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : const Color(0xFFF3F6FA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Explore Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1.0,
            ),
            itemCount: 21,
            itemBuilder: (context, index) {
              final imageUrl = 'https://picsum.photos/seed/explore_$index/400/400';
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(color: Colors.grey.shade100);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
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

          return Material(
            color: Colors.transparent,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: HomeSearchInput(
                            onChanged: (value) =>
                                setState(() => _query = value.trim()),
                            onSubmitted: () {},
                          ),
                        ),
                      ],
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
