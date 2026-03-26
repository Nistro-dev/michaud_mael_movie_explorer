import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_preferences_provider.dart';

class RatingsNotifier extends StateNotifier<Map<int, int>> {
  static const String _key = 'ratings';
  final SharedPreferences _prefs;

  RatingsNotifier(this._prefs) : super({}) {
    _load();
  }

  void _load() {
    final raw = _prefs.getString(_key);
    if (raw != null) {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      state = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
    }
  }

  void setRating(int movieId, int rating) {
    state = {...state, movieId: rating};
    _save();
  }

  void removeRating(int movieId) {
    final updated = Map<int, int>.from(state);
    updated.remove(movieId);
    state = updated;
    _save();
  }

  int? getRating(int movieId) => state[movieId];

  void _save() {
    _prefs.setString(
      _key,
      json.encode(state.map((k, v) => MapEntry(k.toString(), v))),
    );
  }
}

final ratingsProvider = StateNotifierProvider<RatingsNotifier, Map<int, int>>((
  ref,
) {
  return RatingsNotifier(ref.read(sharedPreferencesProvider));
});
