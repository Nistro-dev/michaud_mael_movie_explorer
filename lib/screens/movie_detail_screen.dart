import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final TmdbService _tmdbService = TmdbService();
  bool _isLoadingCredits = true;
  String? _director;
  String? _actors;

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    try {
      final credits = await _tmdbService.getMovieCredits(widget.movie.id);
      setState(() {
        _director = credits['director'];
        _actors = credits['actors'];
        _isLoadingCredits = false;
      });
    } catch (e) {
      setState(() {
        _director = 'N/A';
        _actors = 'N/A';
        _isLoadingCredits = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Détails du film')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Image
            Container(
              width: double.infinity,
              height: 400,
              color: AppColors.cardBackground,
              child: widget.movie.poster.isNotEmpty
                  ? Image.network(
                      widget.movie.poster,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.movie,
                            size: 100,
                            color: AppColors.textDisabled,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.movie,
                        size: 100,
                        color: AppColors.textDisabled,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Rating & Year
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.accent, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        widget.movie.rating,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        ' / 10',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 24),
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.movie.year,
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Genres Section
                  const Text(
                    'Genres',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Genres List
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.movie.genre.split(', ').map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          border: Border.all(color: AppColors.border, width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          genre,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Synopsis Section
                  const Text(
                    'Synopsis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Synopsis Text
                  Text(
                    widget.movie.plot,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Director Section
                  const Text(
                    'Réalisateur',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Director Name
                  _isLoadingCredits
                      ? const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accent,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Chargement...',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _director ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 24),
                  // Actors Section
                  const Text(
                    'Acteurs principaux',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Actors List
                  _isLoadingCredits
                      ? const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accent,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Chargement...',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.people,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _actors ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
