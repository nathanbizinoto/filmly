import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Implementação alternativa usando SharedPreferences para web
/// Isso funciona nativamente na web sem necessidade de arquivos adicionais
class DatabaseHelperWebSharedPrefs {
  static const String _usersKey = 'filmly_users';
  static const String _moviesKey = 'filmly_movies';

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
        final maxId = users.isEmpty ? 0 : (users.map((u) => u['id'] as int? ?? 0).reduce((a, b) => a > b ? a : b));
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
      return users.firstWhere((u) => u['email']?.toLowerCase() == email.toLowerCase());
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
      (movie['tmdb_id'] != null && m['tmdb_id'] == movie['tmdb_id'])
    );
    
    int movieId;
    if (existingIndex != -1) {
      movies[existingIndex] = movie;
      movieId = movie['id'] as int? ?? existingIndex + 1;
    } else {
      // Gera um ID se não tiver
      if (movie['id'] == null) {
        final maxId = movies.isEmpty ? 0 : (movies.map((m) => m['id'] as int? ?? 0).reduce((a, b) => a > b ? a : b));
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
    return movies.where((m) => m['is_favorite'] == true || m['is_favorite'] == 1).toList();
  }

  /// Busca filmes assistidos
  static Future<List<Map<String, dynamic>>> findWatchedMovies() async {
    final movies = await findAllMovies();
    return movies.where((m) => m['is_watched'] == true || m['is_watched'] == 1).toList();
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
}

