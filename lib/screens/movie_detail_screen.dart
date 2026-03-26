import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../models/movie.dart';
import '../providers/favorites_provider.dart';
import '../providers/rating_provider.dart';
import '../providers/history_provider.dart';
import '../providers/movie_providers.dart';

class MovieDetailScreen extends ConsumerStatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  ConsumerState<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends ConsumerState<MovieDetailScreen> {
  bool _isLoadingCredits = true;
  String? _director;
  String? _actors;

  @override
  void initState() {
    super.initState();
    _loadCredits();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).addToHistory(widget.movie);
    });
  }

  Future<void> _loadCredits() async {
    final service = ref.read(tmdbServiceProvider);
    try {
      final credits = await service.getMovieCredits(widget.movie.id);
      if (mounted) {
        setState(() {
          _director = credits['director'];
          _actors = credits['actors'];
          _isLoadingCredits = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _director = 'N/A';
          _actors = 'N/A';
          _isLoadingCredits = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = ref
        .watch(favoritesProvider)
        .any((m) => m.id == widget.movie.id);
    final userRating = ref.watch(ratingsProvider)[widget.movie.id];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détails du film'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : AppColors.textSecondary,
            ),
            onPressed: () =>
                ref.read(favoritesProvider.notifier).toggle(widget.movie),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster with Hero transition
            Hero(
              tag: 'poster_${widget.movie.id}',
              child: Container(
                width: double.infinity,
                height: 400,
                color: AppColors.cardBackground,
                child: widget.movie.poster.isNotEmpty
                    ? Image.network(
                        widget.movie.poster,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.movie,
                                size: 100,
                                color: AppColors.textDisabled,
                              ),
                            ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.movie,
                          size: 100,
                          color: AppColors.textDisabled,
                        ),
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
                  // TMDB Rating & Year
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
                  // User rating
                  const Text(
                    'Ma note',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      final filled =
                          userRating != null && starValue <= userRating;
                      return GestureDetector(
                        onTap: () {
                          if (userRating == starValue) {
                            ref
                                .read(ratingsProvider.notifier)
                                .removeRating(widget.movie.id);
                          } else {
                            ref
                                .read(ratingsProvider.notifier)
                                .setRating(widget.movie.id, starValue);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            filled ? Icons.star : Icons.star_border,
                            color: filled
                                ? AppColors.accent
                                : AppColors.textSecondary,
                            size: 34,
                          ),
                        ),
                      );
                    }),
                  ),
                  if (userRating != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Votre note : $userRating/5',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Genres
                  const Text(
                    'Genres',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  // Synopsis
                  const Text(
                    'Synopsis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movie.plot,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Director
                  const Text(
                    'Réalisateur',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingCredits
                      ? _loadingRow()
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
                  // Actors
                  const Text(
                    'Acteurs principaux',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingCredits
                      ? _loadingRow()
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

  Widget _loadingRow() {
    return const Row(
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
          style: TextStyle(fontSize: 15, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
