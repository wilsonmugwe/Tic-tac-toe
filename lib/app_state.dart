// lib/app_state.dart
//
// This file holds my app-wide UI state that the widgets can listen to.
// Right now I’m only persisting dark mode and exposing a helper to clear
// legacy stats keys that older versions of the app wrote.
//
// Why a separate AppState?
// - I want a single, testable source of truth for top-level settings.
// - Widgets subscribe via Provider and rebuild when notifyListeners() fires.
// - I keep persistence concerns local here (SharedPreferences), so the UI
//   doesn’t need to know how/where values are stored.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  // --- Keys I still support from prior versions or shared modules ---
  // I keep these key names in one place to avoid typos and make future
  // migrations easier.
  static const _kDark   = 'settings.darkMode';
  static const _kWins   = 'stats.wins';
  static const _kLosses = 'stats.losses';
  static const _kDraws  = 'stats.draws';
  static const _kStreak = 'stats.streak';

  // Local cache of current settings. The UI reads these via getters.
  bool _darkMode = false;

  // I lazily fetch and hold a SharedPreferences instance to avoid repeated
  // lookups. This is nullable until _init completes.
  SharedPreferences? _prefs;

  /// Constructor kicks off async initialization.
  /// I don’t block widget build; instead, I load persisted values in the
  /// background and notify listeners when ready.
  AppState() {
    _init();
  }

  /// Public read-only accessor for dark mode so widgets can rebuild off changes.
  bool get darkMode => _darkMode;

  /// One-time async setup:
  /// - Grab SharedPreferences.
  /// - Load persisted dark mode (default false if missing).
  /// - Notify listeners so MaterialApp can switch themes immediately after load.
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _darkMode = _prefs?.getBool(_kDark) ?? false;
    notifyListeners();
  }

  /// Sets dark mode and persists it.
  /// I always update local state first, then write to disk, then notify.
  /// This ensures the UI feels instant, and the preference write can complete
  /// in the background. If persistence fails, the worst case is the app looks
  /// correct for this run but won’t survive a restart—acceptable for this app.
  void setDarkMode(bool v) {
    _darkMode = v;
    _prefs?.setBool(_kDark, v);
    notifyListeners();
  }

  /// Convenience: flip current theme.
  void toggleDarkMode() => setDarkMode(!darkMode);

  /// Clears legacy stats keys from SharedPreferences.
  /// This is safe to call even if those keys were never created.
  /// I keep this here (rather than in a Stats-specific class) because the
  /// UI-level settings screen is where I surface “Reset Stats”.
  Future<void> resetStats() async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    await Future.wait([
      p.remove(_kWins),
      p.remove(_kLosses),
      p.remove(_kDraws),
      p.remove(_kStreak),
    ]);
    // No notify here because AppState does not expose these values directly.
    // If I later surface stats in AppState, I’d notify after clearing.
  }
}
