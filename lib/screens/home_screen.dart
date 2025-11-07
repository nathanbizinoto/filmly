import 'package:flutter/material.dart';
import '../widgets/movie_section.dart';
import '../theme/app_theme.dart';
import '../services/tmdb_service.dart';
import '../models/movie.dart';
import '../database/movie_dao.dart';
import 'favorites_screen.dart';
import 'watched_screen.dart';
import 'profile_screen.dart';

// REQUISITO: screens/ - Telas do app (lista, formulário, detalhes)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final MovieDao _movieDao = MovieDao();
  
  List<Movie> _popularMovies = [];
  List<Movie> _favoriteMovies = [];
  List<Movie> _watchedMovies = [];
  
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarrega favoritos e assistidos quando a tela é acessada novamente
    if (!_loading) {
      _loadFavoritesAndWatched();
    }
  }

  Future<void> _loadMovies() async {
    setState(() {
      _loading = true;
    });
    
    try {
      print('🏠 Carregando filmes para a tela inicial...');
      
      // Carrega filmes populares da API
      final tmdbService = TmdbService();
      final apiMovies = await tmdbService.popularMovies();
      
      // Salva os filmes populares no banco (se ainda não existirem)
      for (var movie in apiMovies) {
        await _movieDao.insertOrUpdate(movie);
      }
      
      // Recarrega do banco para ter os IDs corretos
      final allMovies = await _movieDao.findAll();
      // Filtra apenas os filmes que estão na lista da API (por tmdbId)
      final popularMovies = apiMovies.map((apiMovie) {
        final dbMovie = allMovies.firstWhere(
          (m) => m.tmdbId == apiMovie.tmdbId,
          orElse: () => apiMovie,
        );
        return dbMovie;
      }).toList();
      
      // Carrega favoritos e assistidos do banco
      final favoriteMovies = await _movieDao.findFavorites();
      final watchedMovies = await _movieDao.findWatched();
      
      setState(() {
        _popularMovies = popularMovies;
        _favoriteMovies = favoriteMovies;
        _watchedMovies = watchedMovies;
        _loading = false;
      });
      
      print('✅ ${_popularMovies.length} filmes populares carregados');
      print('✅ ${_favoriteMovies.length} filmes favoritos carregados');
      print('✅ ${_watchedMovies.length} filmes assistidos carregados');
    } catch (e) {
      print('💥 Erro ao carregar filmes na tela inicial: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadFavoritesAndWatched() async {
    try {
      final favoriteMovies = await _movieDao.findFavorites();
      final watchedMovies = await _movieDao.findWatched();
      
      setState(() {
        _favoriteMovies = favoriteMovies;
        _watchedMovies = watchedMovies;
      });
    } catch (e) {
      print('💥 Erro ao recarregar favoritos e assistidos: $e');
    }
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      Navigator.pushNamed(
        context,
        '/movies',
        arguments: query,
      );
    }
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Filmly',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.account_circle_outlined,
                color: AppTheme.textPrimary,
                size: 28,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.list_alt,
                color: AppTheme.textPrimary,
                size: 28,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/movies');
              },
              tooltip: 'Lista dinâmica',
            ),
            const SizedBox(width: 8),
          ],
        ),

        // Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar filmes, séries...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onSubmitted: (value) {
                  _performSearch(value);
                },
              ),
            ),
          ),
        ),

        // Suggestions Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/movies');
                    },
                    icon: const Icon(Icons.trending_up),
                    label: const Text('Tendências'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: AppTheme.textLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/movies');
                    },
                    icon: const Icon(Icons.star),
                    label: const Text('Populares'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: AppTheme.textLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Popular Movies Section
        SliverToBoxAdapter(
          child: MovieSection(
            title: 'Filmes Populares',
            movies: _popularMovies.map((movie) => {
              'id': movie.id,
              'title': movie.title,
              'subtitle': movie.description ?? 'Sem descrição',
              'imageUrl': movie.posterUrl,
              'isFavorite': movie.isFavorite,
              'isWatched': movie.isWatched,
            },).toList(),
            onSeeAll: () {
              Navigator.pushNamed(context, '/movies');
            },
            onFavoriteToggle: (movieId, isFavorite) async {
              if (movieId != null) {
                await _movieDao.updateFavoriteStatus(movieId, isFavorite);
                await _loadFavoritesAndWatched();
                if (mounted) {
                  setState(() {
                    // Atualiza o filme na lista local
                    final index = _popularMovies.indexWhere((m) => m.id == movieId);
                    if (index != -1) {
                      _popularMovies[index] = _popularMovies[index].copyWith(isFavorite: isFavorite);
                    }
                  });
                }
              }
            },
            onWatchedToggle: (movieId, isWatched) async {
              if (movieId != null) {
                await _movieDao.updateWatchedStatus(movieId, isWatched);
                await _loadFavoritesAndWatched();
                if (mounted) {
                  setState(() {
                    // Atualiza o filme na lista local
                    final index = _popularMovies.indexWhere((m) => m.id == movieId);
                    if (index != -1) {
                      _popularMovies[index] = _popularMovies[index].copyWith(isWatched: isWatched);
                    }
                  });
                }
              }
            },
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // Favorites Section
        SliverToBoxAdapter(
          child: MovieSection(
            title: 'Favoritos',
            movies: _favoriteMovies.map((movie) => {
              'id': movie.id,
              'title': movie.title,
              'subtitle': movie.description ?? 'Sem descrição',
              'imageUrl': movie.posterUrl,
              'isFavorite': movie.isFavorite,
              'isWatched': movie.isWatched,
            },).toList(),
            onSeeAll: () {
              Navigator.pushNamed(context, '/favorites');
            },
            onFavoriteToggle: (movieId, isFavorite) async {
              if (movieId != null) {
                await _movieDao.updateFavoriteStatus(movieId, isFavorite);
                await _loadFavoritesAndWatched();
              }
            },
            onWatchedToggle: (movieId, isWatched) async {
              if (movieId != null) {
                await _movieDao.updateWatchedStatus(movieId, isWatched);
                await _loadFavoritesAndWatched();
              }
            },
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // My Movies Section
        SliverToBoxAdapter(
          child: MovieSection(
            title: 'Assistidos',
            movies: _watchedMovies.map((movie) => {
              'id': movie.id,
              'title': movie.title,
              'subtitle': movie.description ?? 'Sem descrição',
              'imageUrl': movie.posterUrl,
              'isFavorite': movie.isFavorite,
              'isWatched': movie.isWatched,
            },).toList(),
            onSeeAll: () {
              Navigator.pushNamed(context, '/watched');
            },
            onFavoriteToggle: (movieId, isFavorite) async {
              if (movieId != null) {
                await _movieDao.updateFavoriteStatus(movieId, isFavorite);
                await _loadFavoritesAndWatched();
              }
            },
            onWatchedToggle: (movieId, isWatched) async {
              if (movieId != null) {
                await _movieDao.updateWatchedStatus(movieId, isWatched);
                await _loadFavoritesAndWatched();
              }
            },
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const FavoritesScreen();
      case 2:
        return const WatchedScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: _getCurrentScreen(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/movies');
          if (!mounted) return;
          if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item criado na lista de filmes.')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_outlined),
              activeIcon: Icon(Icons.movie),
              label: 'Assistidos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}