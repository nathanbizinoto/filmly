import 'package:flutter/material.dart';
import '../widgets/movie_section.dart';
import '../theme/app_theme.dart';
import '../models/movie.dart';
import '../database/movie_dao.dart';

class WatchedScreen extends StatefulWidget {
  const WatchedScreen({super.key});

  @override
  State<WatchedScreen> createState() => _WatchedScreenState();
}

class _WatchedScreenState extends State<WatchedScreen> {
  List<Movie> _watchedMovies = [];
  bool _loading = false;
  String _error = '';
  final MovieDao _movieDao = MovieDao();

  @override
  void initState() {
    super.initState();
    _loadWatchedMovies();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarrega quando a tela é acessada novamente
    _loadWatchedMovies();
  }

  Future<void> _loadWatchedMovies() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      print('🎬 Carregando filmes assistidos do banco de dados...');
      final watchedMovies = await _movieDao.findWatched();

      setState(() {
        _watchedMovies = watchedMovies;
        _loading = false;
      });

      print('✅ ${_watchedMovies.length} filmes assistidos carregados');
    } catch (e) {
      print('💥 Erro ao carregar filmes assistidos: $e');
      setState(() {
        _error = 'Erro ao carregar filmes assistidos: $e';
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
            'Assistidos',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Watched Content
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
                            'Erro ao carregar filmes assistidos',
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
                            onPressed: _loadWatchedMovies,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _watchedMovies.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.movie_filter_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum filme assistido ainda',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Marque filmes como assistidos\npara vê-los aqui',
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
                          title: 'Seus Filmes Assistidos',
                          movies: _watchedMovies
                              .map(
                                (movie) => {
                                  'id': movie.id,
                                  'title': movie.title,
                                  'subtitle':
                                      movie.description ?? 'Sem descrição',
                                  'imageUrl': movie.posterUrl,
                                  'isFavorite': movie.isFavorite,
                                  'isWatched': movie.isWatched,
                                },
                              )
                              .toList(),
                          onFavoriteToggle: (movieId, isFavorite) async {
                            if (movieId != null) {
                              await _movieDao.updateFavoriteStatus(movieId, isFavorite);
                              await _loadWatchedMovies();
                            }
                          },
                          onWatchedToggle: (movieId, isWatched) async {
                            if (movieId != null) {
                              await _movieDao.updateWatchedStatus(movieId, isWatched);
                              await _loadWatchedMovies();
                            }
                          },
                        ),
                      ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
