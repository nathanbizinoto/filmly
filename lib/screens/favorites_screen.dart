import 'package:flutter/material.dart';
import '../widgets/movie_section.dart';
import '../theme/app_theme.dart';
import '../models/movie.dart';
import '../database/movie_dao.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Movie> _favoriteMovies = [];
  bool _loading = false;
  String _error = '';
  final MovieDao _movieDao = MovieDao();

  @override
  void initState() {
    super.initState();
    _loadFavoriteMovies();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarrega quando a tela é acessada novamente
    _loadFavoriteMovies();
  }

  Future<void> _loadFavoriteMovies() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    
    try {
      print('❤️ Carregando filmes favoritos do banco de dados...');
      final favoriteMovies = await _movieDao.findFavorites();
      
      setState(() {
        _favoriteMovies = favoriteMovies;
        _loading = false;
      });
      
      print('✅ ${_favoriteMovies.length} filmes favoritos carregados');
    } catch (e) {
      print('💥 Erro ao carregar favoritos: $e');
      setState(() {
        _error = 'Erro ao carregar favoritos: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

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
        _loading
            ? const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            : _error.isNotEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erro ao carregar favoritos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(_error),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadFavoriteMovies,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _favoriteMovies.isEmpty
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
                          movies: _favoriteMovies.map((movie) => {
                            'id': movie.id,
                            'title': movie.title,
                            'subtitle': movie.description ?? 'Sem descrição',
                            'imageUrl': movie.posterUrl,
                            'isFavorite': movie.isFavorite,
                            'isWatched': movie.isWatched,
                          },).toList(),
                          onFavoriteToggle: (movieId, isFavorite) async {
                            if (movieId != null) {
                              await _movieDao.updateFavoriteStatus(movieId, isFavorite);
                              await _loadFavoriteMovies();
                            }
                          },
                          onWatchedToggle: (movieId, isWatched) async {
                            if (movieId != null) {
                              await _movieDao.updateWatchedStatus(movieId, isWatched);
                              await _loadFavoriteMovies();
                            }
                          },
                        ),
                      ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}