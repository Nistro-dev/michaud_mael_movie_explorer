class Movie {
  final int id;
  final String title;
  final String year;
  final String poster;
  final String plot;
  final String? director;
  final String? actors;
  final String genre;
  final List<int> genreIds;
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
    required this.genreIds,
    required this.rating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    // Handle year
    String year;
    if (json['year'] != null) {
      year = json['year'] as String;
    } else if (json['release_date'] != null &&
        (json['release_date'] as String).isNotEmpty) {
      year = (json['release_date'] as String).split('-')[0];
    } else {
      year = 'N/A';
    }

    // Handle poster
    String poster;
    if (json['poster'] != null && (json['poster'] as String).isNotEmpty) {
      poster = json['poster'] as String;
    } else if (json['poster_path'] != null) {
      poster = 'https://image.tmdb.org/t/p/w500${json['poster_path']}';
    } else {
      poster = '';
    }

    // Handle genres
    List<int> genreIds;
    String genre;
    if (json['genre_ids'] != null) {
      genreIds = List<int>.from(json['genre_ids'] as List);
      genre = json['genre'] as String? ?? _mapGenreIds(genreIds);
    } else {
      genreIds = [];
      genre = json['genre'] as String? ?? 'Unknown';
    }

    // Handle rating
    String rating;
    if (json['vote_average'] != null) {
      final va = json['vote_average'];
      rating = (va is double ? va : (va as num).toDouble()).toStringAsFixed(1);
    } else {
      rating = json['rating'] as String? ?? '0.0';
    }

    return Movie(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Unknown',
      year: year,
      poster: poster,
      plot:
          json['overview'] as String? ??
          json['plot'] as String? ??
          'No plot available',
      director: json['director'] as String?,
      actors: json['actors'] as String?,
      genre: genre,
      genreIds: genreIds,
      rating: rating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'poster': poster,
      'plot': plot,
      'director': director,
      'actors': actors,
      'genre': genre,
      'genre_ids': genreIds,
      'rating': rating,
    };
  }

  static String _mapGenreIds(List<int> genreIds) {
    final genres = genreIds
        .map((id) => genreMap[id])
        .whereType<String>()
        .take(3)
        .toList();
    return genres.isEmpty ? 'Unknown' : genres.join(', ');
  }

  static const Map<int, String> genreMap = {
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
      genreIds: genreIds,
      rating: rating,
    );
  }
}
