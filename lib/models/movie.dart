// REQUISITO: models/ - Classes de modelo, como a Transferencia no BankApp
class Movie {
  int? id;
  final String title;
  final String? description;
  final DateTime createdAt;
  bool isFavorite;
  bool isWatched;
  final String? posterUrl;
  final int? tmdbId;
  final double rating;
  final DateTime updatedAt;

  Movie({
    this.id,
    required this.title,
    this.description,
    DateTime? createdAt,
    this.isFavorite = false,
    this.isWatched = false,
    this.posterUrl,
    this.tmdbId,
    this.rating = 0.0,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Converter para Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'poster_url': posterUrl,
      'tmdb_id': tmdbId,
      'is_favorite': isFavorite ? 1 : 0,
      'is_watched': isWatched ? 1 : 0,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Criar Movie a partir de Map (do SQLite)
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      posterUrl: map['poster_url'],
      tmdbId: map['tmdb_id'],
      isFavorite: map['is_favorite'] == 1,
      isWatched: map['is_watched'] == 1,
      rating: map['rating']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // Criar Movie a partir de dados da API TMDB
  factory Movie.fromTmdb(Map<String, dynamic> tmdbData) {
    return Movie(
      title: tmdbData['title'] ?? tmdbData['name'] ?? 'Título não disponível',
      description: tmdbData['overview'] ?? 'Descrição não disponível',
      posterUrl: tmdbData['poster_path'] != null 
          ? 'https://image.tmdb.org/t/p/w500${tmdbData['poster_path']}'
          : null,
      tmdbId: tmdbData['id'],
      rating: tmdbData['vote_average']?.toDouble() ?? 0.0,
    );
  }

  Movie copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isFavorite,
    bool? isWatched,
    String? posterUrl,
    int? tmdbId,
    double? rating,
    DateTime? updatedAt,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isWatched: isWatched ?? this.isWatched,
      posterUrl: posterUrl ?? this.posterUrl,
      tmdbId: tmdbId ?? this.tmdbId,
      rating: rating ?? this.rating,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Movie{id: $id, title: $title, isFavorite: $isFavorite, isWatched: $isWatched}';
  }
}
