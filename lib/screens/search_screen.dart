import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../providers/search_provider.dart';
import '../widgets/movie_card.dart';
import '../widgets/skeleton_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Rechercher un film...',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            border: InputBorder.none,
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondary,
            ),
            suffixIcon: searchState.query.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchProvider.notifier).clear();
                    },
                  )
                : null,
          ),
          onChanged: (value) =>
              ref.read(searchProvider.notifier).updateQuery(value),
        ),
      ),
      body: _buildBody(searchState),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state.query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
              'Tapez pour rechercher un film',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (state.isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, _) => const SkeletonCard(),
      );
    }

    if (state.error != null) {
      return Center(
        child: Text(
          'Erreur : ${state.error}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    if (state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_filter,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat pour "${state.query}"',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.results.length,
      itemBuilder: (context, index) => MovieCard(movie: state.results[index]),
    );
  }
}
