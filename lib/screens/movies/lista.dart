import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/movie.dart';
import '../../widgets/movie_card.dart';
import '../../services/tmdb_service.dart';
import '../../database/movie_dao.dart';
import 'formulario.dart';

// REQUISITO: screens/ - Telas do app (lista, formulário, detalhes)
class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final List<Movie> _movies = <Movie>[];
  bool _loading = false;
  String _error = '';
  final MovieDao _movieDao = MovieDao();

  @override
  void initState() {
    super.initState();
    _loadAllMovies();
  }

  Future<void> _loadAllMovies() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      print('🚀 Iniciando carregamento de todos os filmes...');
      
      // Carrega filmes do banco de dados
      final dbMovies = await _movieDao.findAll();
      
      // Se não houver filmes no banco, carrega da API e salva
      if (dbMovies.isEmpty) {
        final tmdbService = TmdbService();
        final apiMovies = await tmdbService.popularMovies();
        
        // Salva os filmes da API no banco
        for (var movie in apiMovies) {
          await _movieDao.insertOrUpdate(movie);
        }
        
        // Recarrega do banco
        final savedMovies = await _movieDao.findAll();
        setState(() {
          _movies.clear();
          _movies.addAll(savedMovies);
        });
      } else {
        setState(() {
          _movies.clear();
          _movies.addAll(dbMovies);
        });
      }
      
      print('✅ ${_movies.length} filmes carregados!');
    } catch (e) {
      print('💥 Erro ao carregar filmes: $e');
      setState(() => _error = 'Erro ao carregar filmes: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // REQUISITO: Navegação Entre Telas - Navigator.push() para abrir formulário
  Future<void> _openForm() async {
    final result = await Navigator.push<Movie>(
      context,
      MaterialPageRoute(builder: (_) => const MovieFormScreen()),
    );
    if (result != null) {
      try {
        // Salva o filme no banco de dados
        final id = await _movieDao.insert(result);
        final savedMovie = result.copyWith(id: id);
        
        // REQUISITO: Atualização Dinâmica da Lista - setState() para atualizar lista
        setState(() => _movies.insert(0, savedMovie));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filme adicionado!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar filme: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // REQUISITO: Formatação de Valores - Formatação de data Brasil: dia/mês/ano
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Meus filmes (lista)')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
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
                        'Erro ao carregar filmes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAllMovies,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _movies.isEmpty
                  ? const Center(
                      child: Text('Nenhum filme. Toque em + para adicionar.'),)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _movies.length,
                      itemBuilder: (_, index) {
                        final movie = _movies[index];
                        return MovieCard(
                          title: movie.title,
                          subtitle: movie.description ??
                              'Criado em ${dateFormat.format(movie.createdAt)}',
                          imageUrl: movie.posterUrl,
                          showFavoriteIcon: false,
                          onTap: () {},
                        );
                      },
                    ),
    );
  }
}