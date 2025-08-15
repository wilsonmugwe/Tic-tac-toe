// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/howto_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C4DFF),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Noughts & Crosses',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0, backgroundColor: Colors.transparent),
      ),
      home: const HomeScreen(),
      routes: {
        '/game': (_) => const GameScreen(),
        '/stats': (_) => const StatsScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/howto': (_) => const HowToScreen(),
      },
    );
  }
}
