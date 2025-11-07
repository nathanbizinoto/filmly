import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/secrets.dart';
import '../models/movie.dart';

class TmdbService {
  static const String _base = 'https://api.themoviedb.org/3';
  static const String _images = 'https://image.tmdb.org/t/p/w500';

  final String _apiKey;
  
  TmdbService({String? apiKey}) : _apiKey = apiKey ?? Secrets.tmdbApiKey;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
      };

  Future<List<Movie>> searchMovies(String query) async {
    final uri = Uri.parse('$_base/search/movie?api_key=$_apiKey&language=pt-BR&query=${Uri.encodeQueryComponent(query)}');
    final resp = await http.get(uri, headers: _headers);
    if (resp.statusCode != 200) {
      throw Exception('TMDB search error: ${resp.statusCode}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>?) ?? [];
    
    final movies = results.map((e) {
      final map = e as Map<String, dynamic>;
      return Movie.fromTmdb(map);
    }).toList();
    
    return movies;
  }

  Future<List<Movie>> popularMovies() async {
    final uri = Uri.parse('$_base/movie/popular?api_key=$_apiKey&language=pt-BR&page=1');
    
    try {
      print('🔍 Fazendo requisição para: $uri');
      final resp = await http.get(uri, headers: _headers);
      
      print('📡 Status da resposta: ${resp.statusCode}');
      
      if (resp.statusCode != 200) {
        print('❌ Erro na API: ${resp.statusCode} - ${resp.body}');
        throw Exception('TMDB popular error: ${resp.statusCode} - ${resp.body}');
      }
      
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final results = (data['results'] as List<dynamic>?) ?? [];
      
      print('🎬 Filmes encontrados: ${results.length}');
      
      final movies = results.map((e) {
        final map = e as Map<String, dynamic>;
        final posterPath = map['poster_path'];
        final posterUrl = posterPath != null ? '$_images$posterPath' : null;
        
        print('🎭 Filme: ${map['title']} - Poster: $posterUrl');
        
        return Movie.fromTmdb(map);
      }).toList();
      
      return movies;
    } catch (e) {
      print('💥 Erro na requisição: $e');
      rethrow;
    }
  }
}