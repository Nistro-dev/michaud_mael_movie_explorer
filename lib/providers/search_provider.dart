import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import 'movie_providers.dart';

class SearchState {
  final String query;
  final List<Movie> results;
  final bool isLoading;
  final String? error;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<Movie>? results,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final TmdbService _service;
  Timer? _debounce;

  SearchNotifier(this._service) : super(const SearchState());

  void updateQuery(String query) {
    state = state.copyWith(
      query: query,
      isLoading: query.isNotEmpty,
      error: null,
    );
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await _service.searchMovies(query.trim());
        if (mounted) {
          state = state.copyWith(results: results, isLoading: false);
        }
      } catch (e) {
        if (mounted) {
          state = state.copyWith(
            error: e.toString(),
            isLoading: false,
            results: [],
          );
        }
      }
    });
  }

  void clear() {
    _debounce?.cancel();
    state = const SearchState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  return SearchNotifier(ref.read(tmdbServiceProvider));
});
