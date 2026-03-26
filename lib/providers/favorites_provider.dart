import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import 'shared_preferences_provider.dart';

class FavoritesNotifier extends StateNotifier<List<Movie>> {
  static const String _key = 'favorites';
  final SharedPreferences _prefs;

  FavoritesNotifier(this._prefs) : super([]) {
    _load();
  }

  void _load() {
    final raw = _prefs.getStringList(_key) ?? [];
    state = raw
        .map((s) {
          try {
            return Movie.fromJson(json.decode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<Movie>()
        .toList();
  }

  void toggle(Movie movie) {
    final exists = state.any((m) => m.id == movie.id);
    if (exists) {
      state = state.where((m) => m.id != movie.id).toList();
    } else {
      state = [...state, movie];
    }
    _save();
  }

  bool isFavorite(int movieId) => state.any((m) => m.id == movieId);

  void _save() {
    _prefs.setStringList(
      _key,
      state.map((m) => json.encode(m.toJson())).toList(),
    );
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Movie>>(
  (ref) {
    return FavoritesNotifier(ref.read(sharedPreferencesProvider));
  },
);
