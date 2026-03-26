import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../providers/movie_providers.dart';
import '../widgets/movie_card.dart';
import '../widgets/skeleton_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  static const List<String> _genres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Drama',
    'Fantasy',
    'Horror',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Thriller',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(selectedTabProvider.notifier).state = _tabController.index;
        ref.read(selectedGenreProvider.notifier).state = null;
      }
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final tab = ref.read(selectedTabProvider);
      switch (tab) {
        case 0:
          ref.read(popularMoviesProvider.notifier).loadMore();
          break;
        case 1:
          ref.read(trendingMoviesProvider.notifier).loadMore();
          break;
        case 2:
          ref.read(topRatedMoviesProvider.notifier).loadMore();
          break;
      }
    }
  }

  Future<void> _onRefresh() async {
    final tab = ref.read(selectedTabProvider);
    switch (tab) {
      case 0:
        await ref.read(popularMoviesProvider.notifier).refresh();
        break;
      case 1:
        await ref.read(trendingMoviesProvider.notifier).refresh();
        break;
      case 2:
        await ref.read(topRatedMoviesProvider.notifier).refresh();
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieState = ref.watch(currentMoviesProvider);
    final selectedGenre = ref.watch(selectedGenreProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Movie Explorer',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Populaires'),
            Tab(text: 'Tendances'),
            Tab(text: 'Top Rated'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Genre filter chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _genres.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _genreChip('Tous', selectedGenre == null, () {
                    ref.read(selectedGenreProvider.notifier).state = null;
                  });
                }
                final genre = _genres[index - 1];
                final isSelected = selectedGenre == genre;
                return _genreChip(genre, isSelected, () {
                  ref.read(selectedGenreProvider.notifier).state = isSelected
                      ? null
                      : genre;
                });
              },
            ),
          ),
          // Movie list
          Expanded(child: _buildMovieList(movieState)),
        ],
      ),
    );
  }

  Widget _genreChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.cardBackground,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.black : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMovieList(MovieListState state) {
    if (state.isLoading) {
      return ListView.builder(
        itemCount: 6,
        itemBuilder: (context, _) => const SkeletonCard(),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onRefresh,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state.movies.isEmpty) {
      return const Center(
        child: Text(
          'Aucun film trouvé',
          style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.accent,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.movies.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.movies.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            );
          }
          return MovieCard(movie: state.movies[index]);
        },
      ),
    );
  }
}
