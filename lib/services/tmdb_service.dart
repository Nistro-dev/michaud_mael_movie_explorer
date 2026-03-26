import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class _CacheEntry {
  final Map<String, dynamic> data;
  final DateTime timestamp;
  _CacheEntry(this.data, this.timestamp);
}

class TmdbService {
  static const String _apiKey = 'cbc76e044c1fc15a234f5e1c382c626d';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const Duration _cacheTtl = Duration(minutes: 5);

  final Map<String, _CacheEntry> _cache = {};

  Future<Map<String, dynamic>> _cachedGet(String url) async {
    final now = DateTime.now();
    final cached = _cache[url];
    if (cached != null && now.difference(cached.timestamp) < _cacheTtl) {
      return cached.data;
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      _cache[url] = _CacheEntry(data, now);
      return data;
    }
    throw Exception('HTTP ${response.statusCode}');
  }

  List<Movie> _parseMovies(Map<String, dynamic> data) {
    final results = data['results'] as List<dynamic>? ?? [];
    return results
        .map((j) => Movie.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final url =
        '$_baseUrl/movie/popular?api_key=$_apiKey&language=fr-FR&page=$page';
    try {
      return _parseMovies(await _cachedGet(url));
    } catch (e) {
      throw Exception('Error fetching popular movies: $e');
    }
  }

  Future<List<Movie>> getTrendingMovies({int page = 1}) async {
    final url =
        '$_baseUrl/trending/movie/week?api_key=$_apiKey&language=fr-FR&page=$page';
    try {
      return _parseMovies(await _cachedGet(url));
    } catch (e) {
      throw Exception('Error fetching trending movies: $e');
    }
  }

  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    final url =
        '$_baseUrl/movie/top_rated?api_key=$_apiKey&language=fr-FR&page=$page';
    try {
      return _parseMovies(await _cachedGet(url));
    } catch (e) {
      throw Exception('Error fetching top rated movies: $e');
    }
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    final encoded = Uri.encodeComponent(query.trim());
    final url =
        '$_baseUrl/search/movie?api_key=$_apiKey&language=fr-FR&query=$encoded&page=$page';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return _parseMovies(json.decode(response.body) as Map<String, dynamic>);
      }
      throw Exception('HTTP ${response.statusCode}');
    } catch (e) {
      throw Exception('Error searching movies: $e');
    }
  }

  Future<Map<String, String>> getMovieCredits(int movieId) async {
    final url = '$_baseUrl/movie/$movieId/credits?api_key=$_apiKey';
    try {
      final data = await _cachedGet(url);
      final crew = data['crew'] as List<dynamic>? ?? [];
      final director = crew.firstWhere(
        (p) => p['job'] == 'Director',
        orElse: () => {'name': 'N/A'},
      );
      final cast = data['cast'] as List<dynamic>? ?? [];
      final actors = cast.take(3).map((a) => a['name'] as String).join(', ');
      return {
        'director': director['name'] as String? ?? 'N/A',
        'actors': actors.isNotEmpty ? actors : 'N/A',
      };
    } catch (e) {
      return {'director': 'N/A', 'actors': 'N/A'};
    }
  }

  void clearCache() => _cache.clear();
}
