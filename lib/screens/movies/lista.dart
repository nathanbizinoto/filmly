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
      final data = await _service.popularMovies();
      setState(() => _movies.addAll(data));
    } catch (e) {
      setState(() => _error = 'Falha ao carregar filmes populares');
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
              ? Center(child: Text(_error))
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


