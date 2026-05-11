import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/theme/app_colors.dart';

import '../../../../routes/app_route_path.dart';
import '../../domain/entities/search_entity.dart';
import '../bloc/search_bloc.dart';
import '../widgets/search_widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<SearchBloc>().add(const SearchInitialEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<SearchBloc>().add(const LoadMoreSearchEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.scaffold,
      appBar: AppBar(
        backgroundColor: colors.appBar,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.go(AppRoutes.home.path),
        ),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n.searchLabel,
            hintStyle: TextStyle(color: colors.textSecondary),
            prefixIcon: Icon(Icons.search, color: colors.textSecondary),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close, color: colors.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      context
                          .read<SearchBloc>()
                          .add(const SearchQueryChanged(''));
                      setState(() {});
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: colors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: colors.inputBorder),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            filled: true,
            fillColor: colors.inputFill,
          ),
          onChanged: (value) {
            setState(() {});
            context.read<SearchBloc>().add(SearchQueryChanged(value));
            _debounce?.cancel();

            final normalized = value.trim();
            if (normalized.isEmpty) {
              return;
            }

            _debounce = Timer(const Duration(milliseconds: 600), () {
              if (!mounted) return;
              context.read<SearchBloc>().add(SearchUserEvent(name: normalized));
            });
          },
          onSubmitted: (value) {
            final normalized = value.trim();
            if (normalized.isNotEmpty) {
              context.read<SearchBloc>().add(SearchUserEvent(name: normalized));
            }
          },
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state is SearchHistoryLoadedState &&
                    _searchController.text.isEmpty)
                  _buildSearchHistorySection(context, state)
                else if (state is SearchLoadingState)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state is SearchErrorState)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: colors.error,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(state.message),
                        ],
                      ),
                    ),
                  )
                else if (state is SearchEmptyState)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search,
                            color: colors.textSecondary,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(l10n.searchNoResults),
                        ],
                      ),
                    ),
                  )
                else if (state is SearchLoadedState)
                  _buildSearchResults(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchHistorySection(
    BuildContext context,
    SearchHistoryLoadedState state,
  ) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.history.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recentSearchTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.read<SearchBloc>().add(const ClearSearchHistoryEvent());
                  },
                  child: Text(
                    l10n.clearAllAction,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.history.length,
          itemBuilder: (context, index) {
            final entry = state.history[index];
            return SearchHistoryItem(
              entry: entry,
              onTap: () {
                final label = entry.label.trim();
                if (label.isEmpty) {
                  return;
                }

                _searchController.text = label;
                context.read<SearchBloc>().add(SearchUserEvent(name: label));
                setState(() {});
              },
              onRemove: () {
                // Remove individual history item - you may implement this
                setState(() {});
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    SearchLoadedState state,
  ) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            l10n.searchResultsCount(state.pagination.total),
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.users.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = state.users[index];
            return SearchResultCard(
              user: user,
              onTap: () async {
                final userId = user.id.trim();
                if (userId.isEmpty) {
                  return;
                }

                final displayName = user.displayName.trim();
                final username = user.username.trim();
                final label = displayName.isNotEmpty
                    ? displayName
                    : username.isNotEmpty
                        ? username
                        : userId;

                context.read<SearchBloc>().add(
                      SaveSearchQueryEvent(
                        SearchHistoryEntry.user(
                          label: label,
                          userId: userId,
                          avatarUrl: user.avatarUrl.trim().isNotEmpty
                              ? user.avatarUrl
                              : null,
                        ),
                      ),
                    );

                await context.pushNamed(
                  AppRoutes.otherProfile.name,
                  pathParameters: {'userId': userId},
                );

                if (!mounted) return;
                _searchController.clear();
                setState(() {});
                context.read<SearchBloc>().add(const SearchQueryChanged(''));
              },
            );
          },
        ),
        if (state.pagination.hasMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<SearchBloc>().add(const LoadMoreSearchEvent());
                },
                child: Text(l10n.seeMoreAction),
              ),
            ),
          ),
      ],
    );
  }
}

