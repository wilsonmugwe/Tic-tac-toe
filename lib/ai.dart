// lib/ai.dart
import 'dart:math' as math;
import 'game_logic.dart';

enum Difficulty { easy, medium, hard }

class TicTacAI {
  static int chooseMove(List<Mark> board, Mark ai, Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return _randomMove(board);
      case Difficulty.medium:
        return _mediumMove(board, ai);
      case Difficulty.hard:
        return _minimaxBest(board, ai);
    }
  }

  static int _randomMove(List<Mark> b) {
    final moves = <int>[];
    for (var i = 0; i < 9; i++) {
      if (b[i] == Mark.empty) moves.add(i);
    }
    return moves[math.Random().nextInt(moves.length)];
  }

  static int _mediumMove(List<Mark> b, Mark ai) {
    final opp = ai == Mark.X ? Mark.O : Mark.X;

    for (var i = 0; i < 9; i++) {
      if (b[i] != Mark.empty) continue;
      final copy = List<Mark>.from(b)..[i] = ai;
      if (GameState.checkWinner(copy) == ai) return i;
    }

    for (var i = 0; i < 9; i++) {
      if (b[i] != Mark.empty) continue;
      final copy = List<Mark>.from(b)..[i] = opp;
      if (GameState.checkWinner(copy) == opp) return i;
    }

    if (b[4] == Mark.empty) return 4;

    const corners = [0, 2, 6, 8];
    final freeCorners = corners.where((i) => b[i] == Mark.empty).toList();
    if (freeCorners.isNotEmpty) {
      return freeCorners[math.Random().nextInt(freeCorners.length)];
    }

    final moves = <int>[];
    for (var i = 0; i < 9; i++) {
      if (b[i] == Mark.empty) moves.add(i);
    }
    return moves[math.Random().nextInt(moves.length)];
  }

  static int _minimaxBest(List<Mark> b, Mark ai) {
    final opp = ai == Mark.X ? Mark.O : Mark.X;

    int? terminalScore(List<Mark> s, int depth) {
      final w = GameState.checkWinner(s);
      if (w == ai) return 10 - depth;
      if (w == opp) return depth - 10;
      if (GameState.isDraw(s)) return 0;
      return null;
    }

    int minimax(List<Mark> s, bool maximizing, int depth) {
      final t = terminalScore(s, depth);
      if (t != null) return t;

      if (maximizing) {
        var best = -1000;
        for (var i = 0; i < 9; i++) {
          if (s[i] != Mark.empty) continue;
          s[i] = ai;
          final val = minimax(s, false, depth + 1);
          s[i] = Mark.empty;
          if (val > best) best = val;
        }
        return best;
      } else {
        var best = 1000;
        for (var i = 0; i < 9; i++) {
          if (s[i] != Mark.empty) continue;
          s[i] = opp;
          final val = minimax(s, true, depth + 1);
          s[i] = Mark.empty;
          if (val < best) best = val;
        }
        return best;
      }
    }

    var bestScore = -1000;
    final bestMoves = <int>[];

    for (var i = 0; i < 9; i++) {
      if (b[i] != Mark.empty) continue;
      b[i] = ai;
      final score = minimax(b, false, 0);
      b[i] = Mark.empty;

      if (score > bestScore) {
        bestScore = score;
        bestMoves
          ..clear()
          ..add(i);
      } else if (score == bestScore) {
        bestMoves.add(i);
      }
    }

    if (bestMoves.isEmpty) return _randomMove(b);
    return bestMoves[math.Random().nextInt(bestMoves.length)];
  }
}

/// Extension methods so UI code can ask the AI to move.
extension GameAI on GameState {
  int? aiSuggestMove(Difficulty difficulty, {Mark? aiMark}) {
    if (gameOver) return null;
    final mark = aiMark ?? current;
    return TicTacAI.chooseMove(board, mark, difficulty);
  }

  bool aiPlay(Difficulty difficulty, {Mark? aiMark}) {
    if (gameOver) return false;
    final mark = aiMark ?? current;
    final idx = TicTacAI.chooseMove(board, mark, difficulty);
    if (!isValidMove(idx)) return false;
    playAt(idx);
    return true;
  }
}
