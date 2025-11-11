import '../models/user_movie.dart';
import '../models/movie.dart';
import 'database_helper.dart';
import 'database_helper_web_shared_prefs.dart';
import 'package:flutter/foundation.dart';

class UserMovieDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Inserir uma nova associação usuário-filme
  Future<int> insert(UserMovie userMovie) async {
    if (kIsWeb) {
      // Usa shared_preferences na web
      final userMovieMap = userMovie.toMap();
      final id = await DatabaseHelperWebSharedPrefs.saveUserMovie(userMovieMap);
      return id;
    }
    final db = await _dbHelper.database;
    return await db.insert('user_movies', userMovie.toMap());
  }

  // Buscar associação por usuário e filme
  Future<UserMovie?> findByUserAndMovie(int userId, int movieId) async {
    if (kIsWeb) {
      // Usa shared_preferences na web
      final userMovieMap =
          await DatabaseHelperWebSharedPrefs.findUserMovieByUserAndMovie(
              userId, movieId);
      if (userMovieMap == null) return null;
      return UserMovie.fromMap(userMovieMap);
    }
    final db = await _dbHelper.database;
    final result = await db.query(
      'user_movies',
      where: 'user_id = ? AND movie_id = ?',
      whereArgs: [userId, movieId],
    );
    if (result.isEmpty) return null;
    return UserMovie.fromMap(result.first);
  }

  // Buscar filmes favoritos de um usuário
  Future<List<Movie>> findFavoriteMoviesByUser(int userId) async {
    if (kIsWeb) {
      // Usa shared_preferences na web
      final movies =
          await DatabaseHelperWebSharedPrefs.findFavoriteMoviesByUser(userId);
      return movies.map((map) => Movie.fromMap(map)).toList();
    }
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT m.* FROM movies m
      INNER JOIN user_movies um ON m.id = um.movie_id
      WHERE um.user_id = ? AND um.is_favorite = 1
      ORDER BY um.updated_at DESC
    ''', [userId]);
    return result.map((map) => Movie.fromMap(map)).toList();
  }

  // Buscar filmes assistidos de um usuário
  Future<List<Movie>> findWatchedMoviesByUser(int userId) async {
    if (kIsWeb) {
      // Usa shared_preferences na web
      final movies =
          await DatabaseHelperWebSharedPrefs.findWatchedMoviesByUser(userId);
      return movies.map((map) => Movie.fromMap(map)).toList();
    }
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT m.* FROM movies m
      INNER JOIN user_movies um ON m.id = um.movie_id
      WHERE um.user_id = ? AND um.is_watched = 1
      ORDER BY um.updated_at DESC
    ''', [userId]);
    return result.map((map) => Movie.fromMap(map)).toList();
  }

  // Atualizar status de favorito para um usuário específico
  Future<void> updateFavoriteStatus(
      int userId, int movieId, bool isFavorite) async {
    if (kIsWeb) {
      // Usa shared_preferences na web
      await DatabaseHelperWebSharedPrefs.updateUserMovieFavoriteStatus(
          userId, movieId, isFavorite);
      return;
    }

    final existing = await findByUserAndMovie(userId, movieId);
    if (existing != null) {
      // Atualiza registro existente
      final db = await _dbHelper.database;
      await db.update(
        'user_movies',
        {
          'is_favorite': isFavorite ? 1 : 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ? AND movie_id = ?',
        whereArgs: [userId, movieId],
      );
    } else {
      // Cria novo registro
      final userMovie = UserMovie(
        userId: userId,
        movieId: movieId,
        isFavorite: isFavorite,
        isWatched: false,
      );
      await insert(userMovie);
    }
  }

  // Atualizar status de assistido para um usuário específico
  Future<void> updateWatchedStatus(
      int userId, int movieId, bool isWatched) async {
    if (kIsWeb) {
      // Usa shared_preferences na web
      await DatabaseHelperWebSharedPrefs.updateUserMovieWatchedStatus(
          userId, movieId, isWatched);
      return;
    }

    final existing = await findByUserAndMovie(userId, movieId);
    if (existing != null) {
      // Atualiza registro existente
      final db = await _dbHelper.database;
      await db.update(
        'user_movies',
        {
          'is_watched': isWatched ? 1 : 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ? AND movie_id = ?',
        whereArgs: [userId, movieId],
      );
    } else {
      // Cria novo registro
      final userMovie = UserMovie(
        userId: userId,
        movieId: movieId,
        isFavorite: false,
        isWatched: isWatched,
      );
      await insert(userMovie);
    }
  }

  // Obter status de um filme para um usuário específico
  Future<Map<String, bool>> getMovieStatusForUser(
      int userId, int movieId) async {
    final userMovie = await findByUserAndMovie(userId, movieId);
    return {
      'isFavorite': userMovie?.isFavorite ?? false,
      'isWatched': userMovie?.isWatched ?? false,
    };
  }

  // Deletar associação
  Future<int> delete(int userId, int movieId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'user_movies',
      where: 'user_id = ? AND movie_id = ?',
      whereArgs: [userId, movieId],
    );
  }
}
