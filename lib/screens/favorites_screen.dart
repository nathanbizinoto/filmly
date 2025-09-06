import 'package:flutter/material.dart';
import '../widgets/movie_section.dart';
import '../theme/app_theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock favorite movies data
    final List<Map<String, dynamic>> favoriteMovies = [
      {
        'title': 'Interestelar',
        'subtitle': '2014 • Ficção Científica',
        'isFavorite': true,
      },
      {
        'title': 'O Poderoso Chefão',
        'subtitle': '1972 • Drama',
        'isFavorite': true,
      },
      {'title': 'Pulp Fiction', 'subtitle': '1994 • Crime', 'isFavorite': true},
      {
        'title': 'Top Gun: Maverick',
        'subtitle': '2022 • Ação',
        'isFavorite': true,
      },
      {'title': 'Coringa', 'subtitle': '2019 • Drama', 'isFavorite': true},
    ];

    return CustomScrollView(
      slivers: [
        // App Bar
        const SliverAppBar(
          floating: true,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Favoritos',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Favorites Content
        favoriteMovies.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum favorito ainda',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adicione filmes aos seus favoritos\npara vê-los aqui',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SliverToBoxAdapter(
                child: MovieSection(
                  title: 'Seus Filmes Favoritos',
                  movies: favoriteMovies,
                ),
              ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
