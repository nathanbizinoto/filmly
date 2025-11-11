import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Implementação alternativa usando SharedPreferences para web
/// Isso funciona nativamente na web sem necessidade de arquivos adicionais
class DatabaseHelperWebSharedPrefs {
  static const String _usersKey = 'filmly_users';
  static const String _moviesKey = 'filmly_movies';
  static const String _userMoviesKey = 'filmly_user_movies';

  static Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // ========== USUÁRIOS ==========

  /// Salva um usuário
  static Future<int> saveUser(Map<String, dynamic> user) async {
    final prefs = await _prefs;
    final usersJson = prefs.getString(_usersKey);
    List<Map<String, dynamic>> users = [];

    if (usersJson != null) {
      final decoded = jsonDecode(usersJson) as List;
      users = decoded.cast<Map<String, dynamic>>();
    }

    // Verifica se o email já existe
    final existingIndex = users.indexWhere((u) => u['email'] == user['email']);
    int userId;
    if (existingIndex != -1) {
      users[existingIndex] = user;
      userId = user['id'] as int? ?? existingIndex + 1;
    } else {
      // Gera um ID se não tiver
      if (user['id'] == null) {
        final maxId = users.isEmpty
            ? 0
            : (users
                .map((u) => u['id'] as int? ?? 0)
                .reduce((a, b) => a > b ? a : b));
        user['id'] = maxId + 1;
      }
      userId = user['id'] as int;
      users.add(user);
    }

    await prefs.setString(_usersKey, jsonEncode(users));
    return userId;
  }

  /// Busca usuário por email
  static Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final prefs = await _prefs;
    final usersJson = prefs.getString(_usersKey);

    if (usersJson == null) return null;

    final decoded = jsonDecode(usersJson) as List;
    final users = decoded.cast<Map<String, dynamic>>();

    try {
      return users
          .firstWhere((u) => u['email']?.toLowerCase() == email.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  /// Busca todos os usuários
  static Future<List<Map<String, dynamic>>> findAllUsers() async {
    final prefs = await _prefs;
    final usersJson = prefs.getString(_usersKey);

    if (usersJson == null) return [];

    final decoded = jsonDecode(usersJson) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  // ========== FILMES ==========

  /// Salva um filme
  static Future<int> saveMovie(Map<String, dynamic> movie) async {
    final prefs = await _prefs;
    final moviesJson = prefs.getString(_moviesKey);
    List<Map<String, dynamic>> movies = [];

    if (moviesJson != null) {
      final decoded = jsonDecode(moviesJson) as List;
      movies = decoded.cast<Map<String, dynamic>>();
    }

    // Verifica se o filme já existe (por ID ou tmdbId)
    final existingIndex = movies.indexWhere((m) =>
        (movie['id'] != null && m['id'] == movie['id']) ||
        (movie['tmdb_id'] != null && m['tmdb_id'] == movie['tmdb_id']));

    int movieId;
    if (existingIndex != -1) {
      movies[existingIndex] = movie;
      movieId = movie['id'] as int? ?? existingIndex + 1;
    } else {
      // Gera um ID se não tiver
      if (movie['id'] == null) {
        final maxId = movies.isEmpty
            ? 0
            : (movies
                .map((m) => m['id'] as int? ?? 0)
                .reduce((a, b) => a > b ? a : b));
        movie['id'] = maxId + 1;
      }
      movieId = movie['id'] as int;
      movies.add(movie);
    }

    await prefs.setString(_moviesKey, jsonEncode(movies));
    return movieId;
  }

  /// Busca todos os filmes
  static Future<List<Map<String, dynamic>>> findAllMovies() async {
    final prefs = await _prefs;
    final moviesJson = prefs.getString(_moviesKey);

    if (moviesJson == null) return [];

    final decoded = jsonDecode(moviesJson) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Busca filmes favoritos
  static Future<List<Map<String, dynamic>>> findFavoriteMovies() async {
    final movies = await findAllMovies();
    return movies
        .where((m) => m['is_favorite'] == true || m['is_favorite'] == 1)
        .toList();
  }

  /// Busca filmes assistidos
  static Future<List<Map<String, dynamic>>> findWatchedMovies() async {
    final movies = await findAllMovies();
    return movies
        .where((m) => m['is_watched'] == true || m['is_watched'] == 1)
        .toList();
  }

  /// Atualiza status de favorito
  static Future<void> updateFavoriteStatus(int id, bool isFavorite) async {
    final movies = await findAllMovies();
    final index = movies.indexWhere((m) => m['id'] == id);
    if (index != -1) {
      movies[index]['is_favorite'] = isFavorite;
      movies[index]['updated_at'] = DateTime.now().toIso8601String();
      final prefs = await _prefs;
      await prefs.setString(_moviesKey, jsonEncode(movies));
    }
  }

  /// Atualiza status de assistido
  static Future<void> updateWatchedStatus(int id, bool isWatched) async {
    final movies = await findAllMovies();
    final index = movies.indexWhere((m) => m['id'] == id);
    if (index != -1) {
      movies[index]['is_watched'] = isWatched;
      movies[index]['updated_at'] = DateTime.now().toIso8601String();
      final prefs = await _prefs;
      await prefs.setString(_moviesKey, jsonEncode(movies));
    }
  }

  // ========== USER MOVIES ==========

  /// Salva uma associação usuário-filme
  static Future<int> saveUserMovie(Map<String, dynamic> userMovie) async {
    final prefs = await _prefs;
    final userMoviesJson = prefs.getString(_userMoviesKey);
    List<Map<String, dynamic>> userMovies = [];

    if (userMoviesJson != null) {
      final decoded = jsonDecode(userMoviesJson) as List;
      userMovies = decoded.cast<Map<String, dynamic>>();
    }

    // Verifica se a associação já existe
    final existingIndex = userMovies.indexWhere((um) =>
        um['user_id'] == userMovie['user_id'] &&
        um['movie_id'] == userMovie['movie_id']);

    int userMovieId;
    if (existingIndex != -1) {
      userMovies[existingIndex] = userMovie;
      userMovieId = userMovie['id'] as int? ?? existingIndex + 1;
    } else {
      // Gera um ID se não tiver
      if (userMovie['id'] == null) {
        final maxId = userMovies.isEmpty
            ? 0
            : (userMovies
                .map((um) => um['id'] as int? ?? 0)
                .reduce((a, b) => a > b ? a : b));
        userMovie['id'] = maxId + 1;
      }
      userMovieId = userMovie['id'] as int;
      userMovies.add(userMovie);
    }

    await prefs.setString(_userMoviesKey, jsonEncode(userMovies));
    return userMovieId;
  }

  /// Busca associação por usuário e filme
  static Future<Map<String, dynamic>?> findUserMovieByUserAndMovie(
      int userId, int movieId) async {
    final prefs = await _prefs;
    final userMoviesJson = prefs.getString(_userMoviesKey);

    if (userMoviesJson == null) return null;

    final decoded = jsonDecode(userMoviesJson) as List;
    final userMovies = decoded.cast<Map<String, dynamic>>();

    try {
      return userMovies.firstWhere(
          (um) => um['user_id'] == userId && um['movie_id'] == movieId);
    } catch (e) {
      return null;
    }
  }

  /// Busca filmes favoritos de um usuário
  static Future<List<Map<String, dynamic>>> findFavoriteMoviesByUser(
      int userId) async {
    final prefs = await _prefs;
    final userMoviesJson = prefs.getString(_userMoviesKey);
    final moviesJson = prefs.getString(_moviesKey);

    if (userMoviesJson == null || moviesJson == null) return [];

    final userMoviesDecoded = jsonDecode(userMoviesJson) as List;
    final userMovies = userMoviesDecoded.cast<Map<String, dynamic>>();

    final moviesDecoded = jsonDecode(moviesJson) as List;
    final movies = moviesDecoded.cast<Map<String, dynamic>>();

    final favoriteUserMovies = userMovies
        .where((um) =>
            um['user_id'] == userId &&
            (um['is_favorite'] == true || um['is_favorite'] == 1))
        .toList();

    final favoriteMovies = <Map<String, dynamic>>[];
    for (final userMovie in favoriteUserMovies) {
      final movie = movies.firstWhere((m) => m['id'] == userMovie['movie_id'],
          orElse: () => <String, dynamic>{});
      if (movie.isNotEmpty) {
        favoriteMovies.add(movie);
      }
    }

    return favoriteMovies;
  }

  /// Busca filmes assistidos de um usuário
  static Future<List<Map<String, dynamic>>> findWatchedMoviesByUser(
      int userId) async {
    final prefs = await _prefs;
    final userMoviesJson = prefs.getString(_userMoviesKey);
    final moviesJson = prefs.getString(_moviesKey);

    if (userMoviesJson == null || moviesJson == null) return [];

    final userMoviesDecoded = jsonDecode(userMoviesJson) as List;
    final userMovies = userMoviesDecoded.cast<Map<String, dynamic>>();

    final moviesDecoded = jsonDecode(moviesJson) as List;
    final movies = moviesDecoded.cast<Map<String, dynamic>>();

    final watchedUserMovies = userMovies
        .where((um) =>
            um['user_id'] == userId &&
            (um['is_watched'] == true || um['is_watched'] == 1))
        .toList();

    final watchedMovies = <Map<String, dynamic>>[];
    for (final userMovie in watchedUserMovies) {
      final movie = movies.firstWhere((m) => m['id'] == userMovie['movie_id'],
          orElse: () => <String, dynamic>{});
      if (movie.isNotEmpty) {
        watchedMovies.add(movie);
      }
    }

    return watchedMovies;
  }

  /// Atualiza status de favorito para um usuário específico
  static Future<void> updateUserMovieFavoriteStatus(
      int userId, int movieId, bool isFavorite) async {
    final existing = await findUserMovieByUserAndMovie(userId, movieId);

    if (existing != null) {
      existing['is_favorite'] = isFavorite ? 1 : 0;
      existing['updated_at'] = DateTime.now().toIso8601String();
      await saveUserMovie(existing);
    } else {
      final newUserMovie = {
        'user_id': userId,
        'movie_id': movieId,
        'is_favorite': isFavorite ? 1 : 0,
        'is_watched': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      await saveUserMovie(newUserMovie);
    }
  }

  /// Atualiza status de assistido para um usuário específico
  static Future<void> updateUserMovieWatchedStatus(
      int userId, int movieId, bool isWatched) async {
    final existing = await findUserMovieByUserAndMovie(userId, movieId);

    if (existing != null) {
      existing['is_watched'] = isWatched ? 1 : 0;
      existing['updated_at'] = DateTime.now().toIso8601String();
      await saveUserMovie(existing);
    } else {
      final newUserMovie = {
        'user_id': userId,
        'movie_id': movieId,
        'is_favorite': 0,
        'is_watched': isWatched ? 1 : 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      await saveUserMovie(newUserMovie);
    }
  }
}
