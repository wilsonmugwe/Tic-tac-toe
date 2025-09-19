// lib/main.dart
//
// This file is the entry point of my Flutter app.
// It sets up global state management (via Provider), defines the main App widget,
// configures themes (light/dark), and registers all the available routes.
// Essentially, this file decides how the app boots, what style it uses,
// and how navigation between screens is handled.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart'; // Holds shared app-wide state (e.g., dark mode toggle, settings).
import 'screens/home_screen.dart' show HomeScreen;
import 'screens/game_screen.dart' show GameScreen;
import 'screens/stats_screen.dart' show StatsScreen;
import 'screens/howto_screen.dart' show HowToScreen;

/// The `main` function is the first thing that runs when the app launches.
/// I wrap my entire app in a `ChangeNotifierProvider` so that any widget
/// can listen to and react to changes in the shared `AppState`.
/// For example: toggling dark mode in one place automatically updates the UI everywhere.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const App(),
    ),
  );
}

/// Root widget for the app.
/// I use a StatelessWidget because the actual "state" is not stored here,
/// but instead in the external `AppState` (provided above).
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // I use `context.watch<AppState>()` to reactively rebuild
    // the app whenever the darkMode value changes.
    final darkMode = context.watch<AppState>().darkMode;

    // Define light color scheme: seeded from a purple accent color.
    // Material 3 encourages seeding themes so colors adapt consistently.
    final lightScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C4DFF),
      brightness: Brightness.light,
    );

    // Define dark color scheme: seeded from the same purple so both themes feel cohesive.
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C4DFF),
      brightness: Brightness.dark,
    );

    // Common AppBar theme used in both light and dark modes.
    // I want a flat, centered title with transparent background.
    const commonAppBar = AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
    );

    // The MaterialApp defines:
    // - App title (useful for OS/task switcher)
    // - Theme and darkTheme setup
    // - Home screen to load by default
    // - Named routes for navigation
    return MaterialApp(
      title: 'Noughts & Crosses',
      debugShowCheckedModeBanner: false, // I don’t want the debug banner in dev builds.
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light, // Switch based on AppState.
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
      home: const HomeScreen(), // The first screen users see when they open the app.
      routes: <String, WidgetBuilder>{
        // I register my core navigation routes here for easy access.
        '/game': (_) => const GameScreen(),
        '/stats': (_) => const StatsScreen(),
        '/howto': (_) => const HowToScreen(),
      },
    );
  }
}
