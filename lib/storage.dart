// lib/storage.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'game_logic.dart';

class Stats {
  final int games;
  final int xWins;
  final int oWins;
  final int draws;
  final int movesTotal;
  final DateTime? lastGameAt;

  const Stats({
    required this.games,
    required this.xWins,
    required this.oWins,
    required this.draws,
    required this.movesTotal,
    required this.lastGameAt,
  });

  double get xWinRate => games == 0 ? 0 : xWins / games;
  double get oWinRate => games == 0 ? 0 : oWins / games;
  double get drawRate => games == 0 ? 0 : draws / games;
  double get avgMoves  => games == 0 ? 0 : movesTotal / games;

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

  static const _kGames = 'stats.games';
  static const _kXWins = 'stats.xWins';
  static const _kOWins = 'stats.oWins';
  static const _kDraws = 'stats.draws';
  static const _kMoves = 'stats.movesTotal';
  static const _kLast  = 'stats.lastGameAt';

  static Future<Stats> load(SharedPreferences p) async {
    return Stats(
      games: p.getInt(_kGames) ?? 0,
      xWins: p.getInt(_kXWins) ?? 0,
      oWins: p.getInt(_kOWins) ?? 0,
      draws: p.getInt(_kDraws) ?? 0,
      movesTotal: p.getInt(_kMoves) ?? 0,
      lastGameAt: p.getString(_kLast) == null ? null : DateTime.tryParse(p.getString(_kLast)!),
    );
  }

  Future<void> save(SharedPreferences p) async {
    await p.setInt(_kGames, games);
    await p.setInt(_kXWins, xWins);
    await p.setInt(_kOWins, oWins);
    await p.setInt(_kDraws, draws);
    await p.setInt(_kMoves, movesTotal);
    await p.setString(_kLast, (lastGameAt ?? DateTime.now()).toIso8601String());
  }

  static Future<void> reset(SharedPreferences p) async {
    await p.remove(_kGames);
    await p.remove(_kXWins);
    await p.remove(_kOWins);
    await p.remove(_kDraws);
    await p.remove(_kMoves);
    await p.remove(_kLast);
  }
}

class AppStorage {
  AppStorage._();
  static final instance = AppStorage._();

  Stats? _cache;

  Future<Stats> getStats() async {
    if (_cache != null) return _cache!;
    final p = await SharedPreferences.getInstance();
    _cache = await Stats.load(p);
    return _cache!;
  }

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

  Future<Stats> resetStats() async {
    final p = await SharedPreferences.getInstance();
    await Stats.reset(p);
    _cache = const Stats(games: 0, xWins: 0, oWins: 0, draws: 0, movesTotal: 0, lastGameAt: null);
    return _cache!;
  }
}
