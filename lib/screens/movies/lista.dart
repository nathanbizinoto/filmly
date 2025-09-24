import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/movie.dart';
import '../../widgets/movie_card.dart';
import '../../services/tmdb_service.dart';
import 'formulario.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final List<Movie> _movies = <Movie>[];
  final _service = TmdbService();
  bool _loading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadPopular();
  }

  Future<void> _loadPopular() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      print('🚀 Iniciando carregamento de filmes populares...');
      final data = await _service.popularMovies();
      print('✅ ${data.length} filmes carregados com sucesso!');
      setState(() => _movies.addAll(data));
    } catch (e) {
      print('💥 Erro ao carregar filmes: $e');
      setState(() => _error = 'Erro ao carregar filmes: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm() async {
    final result = await Navigator.push<Movie>(
      context,
      MaterialPageRoute(builder: (_) => const MovieFormScreen()),
    );
    if (result != null) {
      setState(() => _movies.add(result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filme adicionado!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        onPressed: _loadPopular,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _movies.isEmpty
          ? const Center(child: Text('Nenhum filme. Toque em + para adicionar.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _movies.length,
              itemBuilder: (_, index) {
                final movie = _movies[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MovieCard(
                        title: movie.title,
                        subtitle: movie.description ??
                            'Criado em ${dateFormat.format(movie.createdAt)}',
                        imageUrl: movie.posterUrl,
                        showFavoriteIcon: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}


