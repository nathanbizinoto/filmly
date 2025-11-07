import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

// Import condicional para web
import 'database_helper_web_stub.dart'
    if (dart.library.html) 'database_helper_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('filmly.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Inicializa o databaseFactory para web
    if (kIsWeb) {
      initDatabaseForWeb();
    }

    final dbPath = kIsWeb ? '' : await getDatabasesPath();
    final path = kIsWeb ? filePath : join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const integerTypeNullable = 'INTEGER';
    const realType = 'REAL NOT NULL';

    // Tabela de usuários
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        email $textType UNIQUE,
        password_hash $textType,
        name $textTypeNullable,
        created_at $textType,
        updated_at $textType
      )
    ''');

    // Tabela de filmes
    await db.execute('''
      CREATE TABLE movies (
        id $idType,
        title $textType,
        description $textTypeNullable,
        poster_url $textTypeNullable,
        tmdb_id $integerTypeNullable,
        is_favorite $integerType DEFAULT 0,
        is_watched $integerType DEFAULT 0,
        rating $realType DEFAULT 0.0,
        created_at $textType,
        updated_at $textType
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adiciona tabela de usuários se não existir
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          name TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
