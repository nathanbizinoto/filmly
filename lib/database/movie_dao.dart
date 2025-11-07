import '../models/movie.dart';
import 'database_helper.dart';
import 'database_helper_web_shared_prefs.dart';
import 'package:flutter/foundation.dart';

class MovieDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Inserir um novo filme
  Future<int> insert(Movie movie) async {
    if (kIsWeb) {
      // Usa shared_preferences na web
      final movieMap = movie.toMap();
      final id = await DatabaseHelperWebSharedPrefs.saveMovie(movieMap);
      return id;
    }
    final db = await _dbHelper.database;
    return await db.insert('movies', movie.toMap());
  }

  // Buscar todos os filmes
  Future<List<Movie>> findAll() async {
    if (kIsWeb) {
      // Usa shared_preferences na web
      final movies = await DatabaseHelperWebSharedPrefs.findAllMovies();
      return movies.map((map) => Movie.fromMap(map)).toList();
    }
    final db = await _dbHelper.database;
    final result = await db.query('movies', orderBy: 'created_at DESC');
    return result.map((map) => Movie.fromMap(map)).toList();
  }

  // Buscar filme por ID
  Future<Movie?> findById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Movie.fromMap(result.first);
  }

  // Buscar filme por TMDB ID
  Future<Movie?> findByTmdbId(int tmdbId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'movies',
      where: 'tmdb_id = ?',
      whereArgs: [tmdbId],
    );
    if (result.isEmpty) return null;
    return Movie.fromMap(result.first);
  }

  // Buscar filmes favoritos
  Future<List<Movie>> findFavorites() async {
    if (kIsWeb) {
      // Usa shared_preferences na web
      final movies = await DatabaseHelperWebSharedPrefs.findFavoriteMovies();
      return movies.map((map) => Movie.fromMap(map)).toList();
    }
    final db = await _dbHelper.database;
    final result = await db.query(
      'movies',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Movie.fromMap(map)).toList();
  }

  // Buscar filmes assistidos
  Future<List<Movie>> findWatched() async {
    if (kIsWeb) {
      // Usa shared_preferences na web
      final movies = await DatabaseHelperWebSharedPrefs.findWatchedMovies();
      return movies.map((map) => Movie.fromMap(map)).toList();
    }
    final db = await _dbHelper.database;
    final result = await db.query(
      'movies',
      where: 'is_watched = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Movie.fromMap(map)).toList();
  }

  // Atualizar um filme
  Future<int> update(Movie movie) async {
    final db = await _dbHelper.database;
    final updatedMovie = movie.copyWith(updatedAt: DateTime.now());
    return await db.update(
      'movies',
      updatedMovie.toMap(),
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }

  // Atualizar status de favorito
  Future<int> updateFavoriteStatus(int id, bool isFavorite) async {
    if (kIsWeb) {
      // Usa shared_preferences na web
      await DatabaseHelperWebSharedPrefs.updateFavoriteStatus(id, isFavorite);
      return 1;
    }
    final db = await _dbHelper.database;
    return await db.update(
      'movies',
      {
        'is_favorite': isFavorite ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Atualizar status de assistido
  Future<int> updateWatchedStatus(int id, bool isWatched) async {
    if (kIsWeb) {
      // Usa shared_preferences na web
      await DatabaseHelperWebSharedPrefs.updateWatchedStatus(id, isWatched);
      return 1;
    }
    final db = await _dbHelper.database;
    return await db.update(
      'movies',
      {
        'is_watched': isWatched ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Deletar um filme
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Inserir ou atualizar (upsert) - útil para filmes da API TMDB
  Future<int> insertOrUpdate(Movie movie) async {
    if (kIsWeb) {
      // Na web, usa shared_preferences que já faz upsert automaticamente
      final movieMap = movie.toMap();
      return await DatabaseHelperWebSharedPrefs.saveMovie(movieMap);
    }
    if (movie.tmdbId != null) {
      final existing = await findByTmdbId(movie.tmdbId!);
      if (existing != null) {
        // Atualiza o filme existente mantendo o ID do banco
        return await update(movie.copyWith(id: existing.id));
      }
    }
    // Insere novo filme
    return await insert(movie);
  }
}

