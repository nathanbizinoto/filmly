import 'package:flutter/material.dart';
import '../widgets/movie_section.dart';
import '../theme/app_theme.dart';
import '../services/tmdb_service.dart';
import '../models/movie.dart';
import 'favorites_screen.dart';
import 'watched_screen.dart';
import 'profile_screen.dart';
import 'movies/lista.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  
  // Serviço TMDB
  final TmdbService _tmdbService = TmdbService();
  
  // Listas de filmes reais
  List<Movie> _popularMovies = [];
  List<Movie> _favoriteMovies = [];
  List<Movie> _watchedMovies = [];
  
  bool _loading = false;
  String _error = '';

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

  Future<void> _loadMovies() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    
    try {
      print('🏠 Carregando filmes para a tela inicial...');
      final movies = await _tmdbService.popularMovies();
      
      setState(() {
        _popularMovies = movies.take(6).toList(); // Primeiros 6 filmes para sugestões
        _loading = false;
      });
      
      print('✅ ${_popularMovies.length} filmes carregados para a tela inicial');
    } catch (e) {
      print('💥 Erro ao carregar filmes na tela inicial: $e');
      setState(() {
        _error = 'Erro ao carregar filmes: $e';
        _loading = false;
      });
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
                setState(() {
                  _currentIndex = 3; // Navigate to profile tab
                });
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.list_alt,
                color: AppTheme.textPrimary,
                size: 26,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MovieListScreen()),
                );
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
                    color: Colors.black.withValues(alpha: 0.05),
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
                  // TODO: Implement search functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Buscando por: $value')),
                  );
                },
              ),
            ),
          ),
        ),

        // Suggestions Section
        SliverToBoxAdapter(
          child: _loading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _error.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          children: [
                            Text('Erro: $_error'),
                            ElevatedButton(
                              onPressed: _loadMovies,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : MovieSection(
                      title: 'Sugestões',
                      movies: _popularMovies.map((movie) => {
                        'title': movie.title,
                        'subtitle': movie.description ?? 'Sem descrição',
                        'imageUrl': movie.posterUrl,
                        'isFavorite': movie.isFavorite,
                      }).toList(),
                      onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MovieListScreen()),
                        );
                      },
                    ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // Favorites Section
        SliverToBoxAdapter(
          child: MovieSection(
            title: 'Favoritos',
            movies: _favoriteMovies.map((movie) => {
              'title': movie.title,
              'subtitle': movie.description ?? 'Sem descrição',
              'imageUrl': movie.posterUrl,
              'isFavorite': movie.isFavorite,
            }).toList(),
            onSeeAll: () {
              setState(() {
                _currentIndex = 1; // Navigate to favorites tab
              });
            },
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // My Movies Section
        SliverToBoxAdapter(
          child: MovieSection(
            title: 'Assistidos',
            movies: _watchedMovies.map((movie) => {
              'title': movie.title,
              'subtitle': movie.description ?? 'Sem descrição',
              'imageUrl': movie.posterUrl,
              'isFavorite': movie.isFavorite,
            }).toList(),
            onSeeAll: () {
              setState(() {
                _currentIndex = 2; // Navigate to watched tab
              });
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
          // Atalho direto para o formulário, mantendo a home simples.
          final result = await Navigator.pushNamed(context, '/movies');
          if (!mounted) return;
          if (result != null) {
            // Apenas feedback; a lista dinâmica está na tela de Movies.
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
              color: Colors.black.withValues(alpha: 0.1),
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
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
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
