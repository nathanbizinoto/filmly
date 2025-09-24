import 'package:flutter/material.dart';
import '../widgets/movie_section.dart';
import '../widgets/movie_card.dart';
import '../theme/app_theme.dart';
import '../services/tmdb_service.dart';
import '../models/movie.dart';

class WatchedScreen extends StatefulWidget {
  const WatchedScreen({super.key});

  @override
  State<WatchedScreen> createState() => _WatchedScreenState();
}

class _WatchedScreenState extends State<WatchedScreen> {
  final TmdbService _tmdbService = TmdbService();
  List<Movie> _watchedMovies = [];
  bool _loading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadWatchedMovies();
  }

  Future<void> _loadWatchedMovies() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    
    try {
      print('🎬 Carregando filmes assistidos...');
      final movies = await _tmdbService.popularMovies();
      
      // Simular alguns filmes assistidos (filmes 5-10)
      setState(() {
        _watchedMovies = movies.skip(5).take(8).toList();
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

        // Stats Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                      'Filmes', '${_watchedMovies.length}', Icons.movie),
                  _buildStatItem('Horas', '${_watchedMovies.length * 2}h', Icons.access_time),
                  _buildStatItem('Gênero', 'Variado', Icons.category),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // Watched Movies Content
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
                                Icons.movie_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum filme assistido',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Comece a marcar filmes como\nassistidos para vê-los aqui',
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
                          title: 'Filmes Assistidos',
                          movies: _watchedMovies.map((movie) => {
                            'title': movie.title,
                            'subtitle': movie.description ?? 'Sem descrição',
                            'imageUrl': movie.posterUrl,
                            'isFavorite': movie.isFavorite,
                          }).toList(),
                        ),
                      ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
