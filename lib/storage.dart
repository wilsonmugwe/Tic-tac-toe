// lib/storage.dart
//
// This file is responsible for persistent storage of player statistics.
// I use SharedPreferences to save data locally so that stats (games played, wins, draws, etc.)
// are preserved between app launches. 
//
// Two main classes live here:
//
// 1. Stats: 
//    - A plain data object that represents all the tracked statistics.
//    - Knows how to load/save itself from SharedPreferences.
//    - Provides derived metrics like win rates and average moves.
//
// 2. AppStorage:
//    - A lightweight singleton wrapper around SharedPreferences + Stats.
//    - Provides a single access point for recording new games and resetting stats.
//    - Caches the last loaded stats in memory so I don’t reload from disk every time.

import 'package:shared_preferences/shared_preferences.dart';
import 'game_logic.dart'; // Needed for the `Mark` enum (X, O, empty).

/// Represents the game statistics the app is tracking.
/// I keep it immutable (all fields are final, constructor requires all values),
/// so that once created it cannot be modified. Updates are done by creating
/// a new instance via `copyWith`.
class Stats {
  final int games;         // Total number of games played.
  final int xWins;         // How many times X has won.
  final int oWins;         // How many times O has won.
  final int draws;         // How many draws occurred.
  final int movesTotal;    // Total number of moves played across all games.
  final DateTime? lastGameAt; // When the last game was played, or null if none yet.

  const Stats({
    required this.games,
    required this.xWins,
    required this.oWins,
    required this.draws,
    required this.movesTotal,
    required this.lastGameAt,
  });

  // --- Derived metrics ---
  // I calculate these on the fly so I don’t store redundant data.

  double get xWinRate => games == 0 ? 0 : xWins / games;
  double get oWinRate => games == 0 ? 0 : oWins / games;
  double get drawRate => games == 0 ? 0 : draws / games;
  double get avgMoves  => games == 0 ? 0 : movesTotal / games;

  /// Creates a new Stats object by copying the current one and selectively
  /// overriding only the provided fields. 
  /// This lets me "update" immutable stats in a safe way.
  Stats copyWith({
    int? games,
    int? xWins,
    int? oWins,
    int? draws,
    int? movesTotal,
    DateTime? lastGameAt,
  }) => Stats(
    games: games ?? this.games,
    xWins: xWins ?? this.xWins,
    oWins: oWins ?? this.oWins,
    draws: draws ?? this.draws,
    movesTotal: movesTotal ?? this.movesTotal,
    lastGameAt: lastGameAt ?? this.lastGameAt,
  );

  // Keys used to save/retrieve values from SharedPreferences.
  // Keeping them centralized here avoids typos.
  static const _kGames = 'stats.games';
  static const _kXWins = 'stats.xWins';
  static const _kOWins = 'stats.oWins';
  static const _kDraws = 'stats.draws';
  static const _kMoves = 'stats.movesTotal';
  static const _kLast  = 'stats.lastGameAt';

  /// Loads Stats from SharedPreferences.
  /// If no stats exist yet, defaults are zero (or null for lastGameAt).
  static Future<Stats> load(SharedPreferences p) async {
    return Stats(
      games: p.getInt(_kGames) ?? 0,
      xWins: p.getInt(_kXWins) ?? 0,
      oWins: p.getInt(_kOWins) ?? 0,
      draws: p.getInt(_kDraws) ?? 0,
      movesTotal: p.getInt(_kMoves) ?? 0,
      lastGameAt: p.getString(_kLast) == null 
        ? null 
        : DateTime.tryParse(p.getString(_kLast)!),
    );
  }

  /// Saves the current Stats to SharedPreferences.
  /// I always overwrite the stored values with the latest.
  Future<void> save(SharedPreferences p) async {
    await p.setInt(_kGames, games);
    await p.setInt(_kXWins, xWins);
    await p.setInt(_kOWins, oWins);
    await p.setInt(_kDraws, draws);
    await p.setInt(_kMoves, movesTotal);
    await p.setString(
      _kLast, 
      (lastGameAt ?? DateTime.now()).toIso8601String()
    );
  }

  /// Resets all stored stats by removing the keys from SharedPreferences.
  /// After this, when I reload, the defaults (all zero/null) will apply.
  static Future<void> reset(SharedPreferences p) async {
    await p.remove(_kGames);
    await p.remove(_kXWins);
    await p.remove(_kOWins);
    await p.remove(_kDraws);
    await p.remove(_kMoves);
    await p.remove(_kLast);
  }
}

/// Wrapper class that centralizes access to stats.
/// I use the singleton pattern here (`instance`) so that the whole app
/// interacts with one storage manager, avoiding multiple inconsistent copies.
class AppStorage {
  AppStorage._(); // Private constructor (can only be used internally).
  static final instance = AppStorage._();

  Stats? _cache; // Holds the most recently loaded stats in memory.

  /// Returns the latest stats.
  /// If I’ve already loaded stats into the cache, I return those immediately.
  /// Otherwise, I load from SharedPreferences and update the cache.
  Future<Stats> getStats() async {
    if (_cache != null) return _cache!;
    final p = await SharedPreferences.getInstance();
    _cache = await Stats.load(p);
    return _cache!;
  }

  /// Records the result of a completed game and updates stats accordingly.
  /// - Increments total games played.
  /// - Adds a win to X or O depending on the winner.
  /// - If there was no winner, increments draws.
  /// - Adds to the total move count.
  /// - Updates `lastGameAt` with the current time.
  /// After updating, I save the new stats and update the cache.
  Future<Stats> recordGame({Mark? winner, required int moves}) async {
    final p = await SharedPreferences.getInstance();
    var s = await Stats.load(p);
    s = s.copyWith(
      games: s.games + 1,
      xWins: s.xWins + ((winner == Mark.X) ? 1 : 0),
      oWins: s.oWins + ((winner == Mark.O) ? 1 : 0),
      draws: s.draws + ((winner == null || winner == Mark.empty) ? 1 : 0),
      movesTotal: s.movesTotal + moves,
      lastGameAt: DateTime.now(),
    );
    await s.save(p);
    _cache = s;
    return s;
  }

  /// Completely resets stats back to zero values and clears storage.
  /// Also refreshes the cache so the in-memory values stay consistent.
  Future<Stats> resetStats() async {
    final p = await SharedPreferences.getInstance();
    await Stats.reset(p);
    _cache = const Stats(
      games: 0, 
      xWins: 0, 
      oWins: 0, 
      draws: 0, 
      movesTotal: 0, 
      lastGameAt: null
    );
    return _cache!;
  }
}
