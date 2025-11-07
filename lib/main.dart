import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/movies/lista.dart';
import 'theme/app_theme.dart';
import 'screens/favorites_screen.dart';
import 'screens/watched_screen.dart';
import 'screens/profile_screen.dart';

// REQUISITO: main.dart - Ponto de entrada e configuração global do aplicativo
void main() {
  runApp(const FilmlyApp());
}

class FilmlyApp extends StatelessWidget {
  const FilmlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filmly',
      debugShowCheckedModeBanner: false,
      // REQUISITO: Temas e Estilização - Configurar um tema global usando ThemeData
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/movies': (context) => const MovieListScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/watched': (context) => const WatchedScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}