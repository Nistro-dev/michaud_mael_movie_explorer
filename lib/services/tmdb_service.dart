import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class TmdbService {
  static const String apiKey = 'cbc76e044c1fc15a234f5e1c382c626d';
  static const String accessToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjYmM3NmUwNDRjMWZjMTVhMjM0ZjVlMWMzODJjNjI2ZCIsIm5iZiI6MTc3MzkzMzU5Mi41ODA5OTk5LCJzdWIiOiI2OWJjMTQxODljMzk1NWFhY2IyM2RiNzQiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.Nf4_v4C-waQMQqLhgtCEfz2Swi9tP0xSdpYtMxD4uwY';
  static const String baseUrl = 'https://api.themoviedb.org/3';

  // Get popular movies
  Future<List<Movie>> getPopularMovies() async {
    final url = Uri.parse(
      '$baseUrl/movie/popular?api_key=$apiKey&language=fr-FR',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movies: $e');
    }
  }

  // Get movie details (director + actors)
  Future<Map<String, String>> getMovieCredits(int movieId) async {
    final url = Uri.parse('$baseUrl/movie/$movieId/credits?api_key=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Get director
        final List<dynamic> crew = data['crew'] ?? [];
        final director = crew.firstWhere(
          (person) => person['job'] == 'Director',
          orElse: () => {'name': 'N/A'},
        );

        // Get actors (top 3)
        final List<dynamic> cast = data['cast'] ?? [];
        final actors = cast.take(3).map((actor) => actor['name']).join(', ');

        return {
          'director': director['name'] ?? 'N/A',
          'actors': actors.isNotEmpty ? actors : 'N/A',
        };
      } else {
        throw Exception('Failed to load credits: ${response.statusCode}');
      }
    } catch (e) {
      return {'director': 'N/A', 'actors': 'N/A'};
    }
  }
}
