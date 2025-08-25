// lib/settings_store.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai.dart'; // for Difficulty enum

class SettingsStore extends ChangeNotifier {
  // --- Defaults ---
  bool _soundOn = true;
  bool _hapticsOn = true;
  bool _undoEnabled = true;
  bool _darkMode = false;
  Difficulty _difficulty = Difficulty.medium;

  // --- Keys ---
  static const _kSound = 'settings.soundOn';
  static const _kHaptics = 'settings.hapticsOn';
  static const _kUndo = 'settings.undoEnabled';
  static const _kDark = 'settings.darkMode';
  static const _kDifficulty = 'settings.difficulty';

  // Optional stat keys your app may use
  static const _kWins = 'stats.wins';
  static const _kLosses = 'stats.losses';
  static const _kDraws = 'stats.draws';
  static const _kStreak = 'stats.streak';

  SharedPreferences? _prefs;

  SettingsStore() {
    _init(); // fire-and-forget load; notifies when done
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _soundOn = _prefs?.getBool(_kSound) ?? _soundOn;
    _hapticsOn = _prefs?.getBool(_kHaptics) ?? _hapticsOn;
    _undoEnabled = _prefs?.getBool(_kUndo) ?? _undoEnabled;
    _darkMode = _prefs?.getBool(_kDark) ?? _darkMode;

    final diffIndex = _prefs?.getInt(_kDifficulty);
    if (diffIndex != null && diffIndex >= 0 && diffIndex < Difficulty.values.length) {
      _difficulty = Difficulty.values[diffIndex];
    }
    notifyListeners();
  }

  // --- Getters ---
  bool get soundOn => _soundOn;
  bool get hapticsOn => _hapticsOn;
  bool get undoEnabled => _undoEnabled;
  bool get darkMode => _darkMode;
  Difficulty get difficulty => _difficulty;

  // --- Setters (persist + notify) ---
  void setSoundOn(bool v) {
    _soundOn = v;
    _prefs?.setBool(_kSound, v);
    notifyListeners();
  }

  void setHapticsOn(bool v) {
    _hapticsOn = v;
    _prefs?.setBool(_kHaptics, v);
    notifyListeners();
  }

  void setUndoEnabled(bool v) {
    _undoEnabled = v;
    _prefs?.setBool(_kUndo, v);
    notifyListeners();
  }

  void setDarkMode(bool v) {
    _darkMode = v;
    _prefs?.setBool(_kDark, v);
    notifyListeners();
  }

  void setDifficulty(Difficulty d) {
    _difficulty = d;
    _prefs?.setInt(_kDifficulty, d.index);
    notifyListeners();
  }

  /// Clears common stat keys if they exist. Safe to call even if you
  /// haven’t implemented stats yet.
  Future<void> resetStats() async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    await Future.wait([
      p.remove(_kWins),
      p.remove(_kLosses),
      p.remove(_kDraws),
      p.remove(_kStreak),
    ]);
  }
}
