import 'package:flutter/material.dart';

class Movie {
  final String title;
  final String? description;
  final DateTime createdAt;
  final bool isFavorite;
  final String? posterUrl;

  Movie({
    required this.title,
    this.description,
    DateTime? createdAt,
    this.isFavorite = false,
    this.posterUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  Movie copyWith({
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isFavorite,
    String? posterUrl,
  }) {
    return Movie(
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      posterUrl: posterUrl ?? this.posterUrl,
    );
  }
}


