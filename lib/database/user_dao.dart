import '../models/user.dart';
import 'database_helper.dart';
import 'database_helper_web_shared_prefs.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class UserDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Gerar hash SHA-256 da senha
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Verificar senha
  bool _verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }

  // Inserir um novo usuário
  Future<int> insert(User user) async {
    if (kIsWeb) {
      // Usa shared_preferences na web
      final userMap = user.toMap();
      final id = await DatabaseHelperWebSharedPrefs.saveUser(userMap);
      return id;
    }
    final db = await _dbHelper.database;
    return await db.insert('users', user.toMap());
  }

  // Criar um novo usuário com senha (faz hash automaticamente)
  Future<int> createUser(String email, String password, {String? name}) async {
    final passwordHash = _hashPassword(password);
    final user = User(
      email: email,
      passwordHash: passwordHash,
      name: name,
    );
    return await insert(user);
  }

  // Buscar usuário por email
  Future<User?> findByEmail(String email) async {
    if (kIsWeb) {
      // Usa shared_preferences na web
      final userMap = await DatabaseHelperWebSharedPrefs.findUserByEmail(email);
      if (userMap == null) return null;
      return User.fromMap(userMap);
    }
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  // Buscar usuário por ID
  Future<User?> findById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  // Autenticar usuário (verifica email e senha)
  Future<User?> authenticate(String email, String password) async {
    final user = await findByEmail(email);
    if (user == null) return null;
    
    if (_verifyPassword(password, user.passwordHash)) {
      return user;
    }
    return null;
  }

  // Verificar se email já existe
  Future<bool> emailExists(String email) async {
    final user = await findByEmail(email);
    return user != null;
  }

  // Atualizar um usuário
  Future<int> update(User user) async {
    final db = await _dbHelper.database;
    final updatedUser = user.copyWith(updatedAt: DateTime.now());
    return await db.update(
      'users',
      updatedUser.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Atualizar senha do usuário
  Future<int> updatePassword(int userId, String newPassword) async {
    final db = await _dbHelper.database;
    final passwordHash = _hashPassword(newPassword);
    return await db.update(
      'users',
      {
        'password_hash': passwordHash,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Deletar um usuário
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Buscar todos os usuários (útil para admin)
  Future<List<User>> findAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('users', orderBy: 'created_at DESC');
    return result.map((map) => User.fromMap(map)).toList();
  }
}

