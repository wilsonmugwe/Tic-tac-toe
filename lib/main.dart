// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'settings_store.dart';
import 'screens/home_screen.dart' show HomeScreen;
import 'screens/game_screen.dart' show GameScreen;
import 'screens/stats_screen.dart' show StatsScreen;
import 'screens/settings_screen.dart' show SettingsScreen;
import 'screens/howto_screen.dart' show HowToScreen;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsStore(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final darkMode = context.watch<SettingsStore>().darkMode;

    final lightScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C4DFF),
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C4DFF),
      brightness: Brightness.dark,
    );

    final commonAppBar = const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
    );

    return MaterialApp(
      title: 'Noughts & Crosses',
      debugShowCheckedModeBanner: false,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: lightScheme,
        useMaterial3: true,
        appBarTheme: commonAppBar,
      ),
      darkTheme: ThemeData(
        colorScheme: darkScheme,
        useMaterial3: true,
        appBarTheme: commonAppBar,
      ),
      home: const HomeScreen(),
      routes: <String, WidgetBuilder>{
        '/game': (_) => const GameScreen(),
        '/stats': (_) => const StatsScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/howto': (_) => const HowToScreen(),
      },
    );
  }
}
