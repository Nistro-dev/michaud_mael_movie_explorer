import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';

final tmdbServiceProvider = Provider<TmdbService>((ref) => TmdbService());

// ---- Movie list state ----

class MovieListState {
  final List<Movie> movies;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int currentPage;

  const MovieListState({
    this.movies = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 0,
  });

  MovieListState copyWith({
    List<Movie>? movies,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    int? currentPage,
  }) {
    return MovieListState(
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class MovieListNotifier extends StateNotifier<MovieListState> {
  final Future<List<Movie>> Function(int page) _fetcher;

  MovieListNotifier(this._fetcher) : super(const MovieListState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      movies: [],
      currentPage: 0,
      hasMore: true,
    );
    try {
      final movies = await _fetcher(1);
      state = state.copyWith(
        isLoading: false,
        movies: movies,
        currentPage: 1,
        hasMore: movies.length >= 20,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final newMovies = await _fetcher(nextPage);
      state = state.copyWith(
        isLoadingMore: false,
        movies: [...state.movies, ...newMovies],
        currentPage: nextPage,
        hasMore: newMovies.length >= 20,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() => loadInitial();
}

final popularMoviesProvider =
    StateNotifierProvider<MovieListNotifier, MovieListState>((ref) {
      final service = ref.read(tmdbServiceProvider);
      return MovieListNotifier((page) => service.getPopularMovies(page: page));
    });

final trendingMoviesProvider =
    StateNotifierProvider<MovieListNotifier, MovieListState>((ref) {
      final service = ref.read(tmdbServiceProvider);
      return MovieListNotifier((page) => service.getTrendingMovies(page: page));
    });

final topRatedMoviesProvider =
    StateNotifierProvider<MovieListNotifier, MovieListState>((ref) {
      final service = ref.read(tmdbServiceProvider);
      return MovieListNotifier((page) => service.getTopRatedMovies(page: page));
    });

// Selected tab: 0=popular, 1=trending, 2=topRated
final selectedTabProvider = StateProvider<int>((ref) => 0);

// Selected genre filter (null = all genres)
final selectedGenreProvider = StateProvider<String?>((ref) => null);

// Filtered movies for the current tab
final currentMoviesProvider = Provider<MovieListState>((ref) {
  final tab = ref.watch(selectedTabProvider);
  final genre = ref.watch(selectedGenreProvider);

  final MovieListState raw;
  switch (tab) {
    case 1:
      raw = ref.watch(trendingMoviesProvider);
      break;
    case 2:
      raw = ref.watch(topRatedMoviesProvider);
      break;
    default:
      raw = ref.watch(popularMoviesProvider);
  }

  if (genre == null || raw.movies.isEmpty) return raw;

  final filtered = raw.movies.where((m) => m.genre.contains(genre)).toList();
  return raw.copyWith(movies: filtered);
});
