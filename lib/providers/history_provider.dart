import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import 'shared_preferences_provider.dart';

class HistoryNotifier extends StateNotifier<List<Movie>> {
  static const String _key = 'history';
  static const int _maxItems = 30;
  final SharedPreferences _prefs;

  HistoryNotifier(this._prefs) : super([]) {
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

  void addToHistory(Movie movie) {
    final filtered = state.where((m) => m.id != movie.id).toList();
    state = [movie, ...filtered].take(_maxItems).toList();
    _save();
  }

  void removeFromHistory(int movieId) {
    state = state.where((m) => m.id != movieId).toList();
    _save();
  }

  void clearHistory() {
    state = [];
    _prefs.remove(_key);
  }

  void _save() {
    _prefs.setStringList(
      _key,
      state.map((m) => json.encode(m.toJson())).toList(),
    );
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, List<Movie>>((
  ref,
) {
  return HistoryNotifier(ref.read(sharedPreferencesProvider));
});
