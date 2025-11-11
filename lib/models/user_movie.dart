class UserMovie {
  int? id;
  final int userId;
  final int movieId;
  final bool isFavorite;
  final bool isWatched;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserMovie({
    this.id,
    required this.userId,
    required this.movieId,
    this.isFavorite = false,
    this.isWatched = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Converter para Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'movie_id': movieId,
      'is_favorite': isFavorite ? 1 : 0,
      'is_watched': isWatched ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Criar UserMovie a partir de Map (do SQLite)
  factory UserMovie.fromMap(Map<String, dynamic> map) {
    return UserMovie(
      id: map['id'],
      userId: map['user_id'],
      movieId: map['movie_id'],
      isFavorite: map['is_favorite'] == 1,
      isWatched: map['is_watched'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  UserMovie copyWith({
    int? id,
    int? userId,
    int? movieId,
    bool? isFavorite,
    bool? isWatched,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserMovie(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieId: movieId ?? this.movieId,
      isFavorite: isFavorite ?? this.isFavorite,
      isWatched: isWatched ?? this.isWatched,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserMovie{id: $id, userId: $userId, movieId: $movieId, isFavorite: $isFavorite, isWatched: $isWatched}';
  }
}
