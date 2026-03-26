class Movie {
  final int id;
  final String title;
  final String year;
  final String poster;
  final String plot;
  final String? director;
  final String? actors;
  final String genre;
  final String rating;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.poster,
    required this.plot,
    this.director,
    this.actors,
    required this.genre,
    required this.rating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      year: json['release_date'] != null && json['release_date'].isNotEmpty
          ? json['release_date'].split('-')[0]
          : 'N/A',
      poster: json['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
          : '',
      plot: json['overview'] ?? 'No plot available',
      director: null,
      actors: null,
      genre: json['genre_ids'] != null
          ? _mapGenreIds(json['genre_ids'])
          : 'Unknown',
      rating: json['vote_average'] != null
          ? json['vote_average'].toStringAsFixed(1)
          : '0.0',
    );
  }

  static String _mapGenreIds(List<dynamic> genreIds) {
    final Map<int, String> genreMap = {
      28: 'Action',
      12: 'Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Sci-Fi',
      10770: 'TV Movie',
      53: 'Thriller',
      10752: 'War',
      37: 'Western',
    };

    final List<String> genres = genreIds
        .map((id) => genreMap[id] ?? 'Unknown')
        .take(3)
        .toList();

    return genres.join(', ');
  }

  Movie copyWith({String? director, String? actors}) {
    return Movie(
      id: id,
      title: title,
      year: year,
      poster: poster,
      plot: plot,
      director: director ?? this.director,
      actors: actors ?? this.actors,
      genre: genre,
      rating: rating,
    );
  }
}
