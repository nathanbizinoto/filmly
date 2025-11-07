import 'package:flutter/material.dart';
import 'movie_card.dart';

class MovieSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> movies;
  final VoidCallback? onSeeAll;
  final Function(int? movieId, bool isFavorite)? onFavoriteToggle;
  final Function(int? movieId, bool isWatched)? onWatchedToggle;

  const MovieSection({
    super.key,
    required this.title,
    required this.movies,
    this.onSeeAll,
    this.onFavoriteToggle,
    this.onWatchedToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text(
                    'Ver todos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Movies List
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              final movieId = movie['id'] as int?;
              final isFavorite = movie['isFavorite'] ?? false;
              final isWatched = movie['isWatched'] ?? false;
              
              return MovieCard(
                title: movie['title'] ?? 'Título do Filme',
                subtitle: movie['subtitle'],
                imageUrl: movie['imageUrl'],
                isFavorite: isFavorite,
                isWatched: isWatched,
                onTap: () {
                  // TODO: Navigate to movie details
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Clicou em: ${movie['title']}'),
                    ),
                  );
                },
                onFavoritePressed: movieId != null && onFavoriteToggle != null
                    ? () => onFavoriteToggle!(movieId, !isFavorite)
                    : null,
                onWatchedPressed: movieId != null && onWatchedToggle != null
                    ? () => onWatchedToggle!(movieId, !isWatched)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
