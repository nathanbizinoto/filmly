import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../database/user_dao.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  static const String _currentUserIdKey = 'current_user_id';
  static const String _currentUserEmailKey = 'current_user_email';

  User? _currentUser;
  final UserDao _userDao = UserDao();

  /// Obtém o usuário logado atualmente
  User? get currentUser => _currentUser;

  /// Verifica se há um usuário logado
  bool get isLoggedIn => _currentUser != null;

  /// Faz login do usuário e salva a sessão
  Future<bool> login(String email, String password) async {
    try {
      final user = await _userDao.authenticate(email, password);
      if (user != null) {
        _currentUser = user;
        await _saveSession(user);
        return true;
      }
      return false;
    } catch (e) {
      print('Erro no login: $e');
      return false;
    }
  }

  /// Carrega a sessão salva (chamado na inicialização do app)
  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_currentUserIdKey);
      final userEmail = prefs.getString(_currentUserEmailKey);

      if (userId != null && userEmail != null) {
        // Tenta carregar por ID primeiro, depois por email
        User? user = await _userDao.findById(userId);
        user ??= await _userDao.findByEmail(userEmail);

        if (user != null) {
          _currentUser = user;
          print('Sessão carregada: ${user.name ?? user.email}');
        } else {
          // Limpa sessão inválida
          await clearSession();
        }
      }
    } catch (e) {
      print('Erro ao carregar sessão: $e');
      await clearSession();
    }
  }

  /// Salva a sessão do usuário
  Future<void> _saveSession(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_currentUserIdKey, user.id ?? 0);
      await prefs.setString(_currentUserEmailKey, user.email);
      print('Sessão salva: ${user.name ?? user.email}');
    } catch (e) {
      print('Erro ao salvar sessão: $e');
    }
  }

  /// Faz logout e limpa a sessão
  Future<void> logout() async {
    _currentUser = null;
    await clearSession();
  }

  /// Limpa os dados da sessão
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserIdKey);
      await prefs.remove(_currentUserEmailKey);
      print('Sessão limpa');
    } catch (e) {
      print('Erro ao limpar sessão: $e');
    }
  }

  /// Atualiza os dados do usuário na sessão
  Future<void> updateCurrentUser(User user) async {
    _currentUser = user;
    await _saveSession(user);
  }
}
