// lib/ai.dart
//
// This file implements the computer opponent for Noughts & Crosses.
// I support three difficulty levels with distinct strategies:
//   - easy:    purely random legal move (good for beginners)
//   - medium:  “opportunistic” heuristics (win if possible, block, take center,
//              then corners, else random)
//   - hard:    full minimax search with depth-based scoring (optimal play)
//
// Design goals:
// - Keep this logic framework-agnostic (no Flutter imports).
// - Make the API simple for the UI layer: chooseMove(board, ai, difficulty).
// - Ensure hard mode is unbeatable while still adding a small randomness factor
//   when multiple optimal moves exist so games don’t feel robotic.

import 'dart:math' as math;
import 'game_logic.dart';

/// Difficulty modes for the AI:
/// - easy:    no lookahead, pick any free cell at random.
/// - medium:  1-ply lookahead to win or block + simple priority rules.
/// - hard:    full minimax with depth-sensitive scoring (classic Tic-Tac-Toe AI).
enum Difficulty { easy, medium, hard }

class TicTacAI {
  /// Top-level move chooser. Given a board state, the AI’s mark, and a difficulty,
  /// return the index (0..8) the AI wants to play.
  /// I keep this static so it’s easy to call without managing instances.
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

  /// Selects a uniformly random legal move.
  /// Useful for “training wheels” mode or for testing basic integration.
  static int _randomMove(List<Mark> b) {
    final moves = <int>[];
    for (var i = 0; i < 9; i++) {
      if (b[i] == Mark.empty) moves.add(i);
    }
    return moves[math.Random().nextInt(moves.length)];
  }

  /// A simple but effective heuristic AI:
  /// 1) If I can win in one move, do it.
  /// 2) Otherwise, if the opponent can win next move, block it.
  /// 3) Otherwise, take the center if it’s free (best general-purpose square).
  /// 4) Otherwise, prefer a random free corner (strong in early play).
  /// 5) Otherwise, pick a random legal move.
  ///
  /// This is intentionally shallow (no full search) but plays “smart enough”
  /// for casual games and to demonstrate incremental AI complexity.
  static int _mediumMove(List<Mark> b, Mark ai) {
    final opp = ai == Mark.X ? Mark.O : Mark.X;

    // 1) Immediate win if available.
    for (var i = 0; i < 9; i++) {
      if (b[i] != Mark.empty) continue;
      final copy = List<Mark>.from(b)..[i] = ai;
      if (GameState.checkWinner(copy) == ai) return i;
    }

    // 2) Immediate block if opponent could win.
    for (var i = 0; i < 9; i++) {
      if (b[i] != Mark.empty) continue;
      final copy = List<Mark>.from(b)..[i] = opp;
      if (GameState.checkWinner(copy) == opp) return i;
    }

    // 3) Take center if free.
    if (b[4] == Mark.empty) return 4;

    // 4) Prefer a random corner out of those still free.
    const corners = [0, 2, 6, 8];
    final freeCorners = corners.where((i) => b[i] == Mark.empty).toList();
    if (freeCorners.isNotEmpty) {
      return freeCorners[math.Random().nextInt(freeCorners.length)];
    }

    // 5) Fallback: any random legal move.
    final moves = <int>[];
    for (var i = 0; i < 9; i++) {
      if (b[i] == Mark.empty) moves.add(i);
    }
    return moves[math.Random().nextInt(moves.length)];
  }

  /// Full minimax search with a depth-based score:
  /// - A win for the AI scores as (10 - depth) so faster wins are preferred.
  /// - A loss scores as (depth - 10) so slower losses are "less bad" if
  ///   unavoidable (the search still avoids them if there is any drawing/winning line).
  /// - A draw scores 0.
  ///
  /// Why depth-based scoring?
  /// Classic Tic-Tac-Toe has small search space; depth weighting breaks ties
  /// between equivalent terminal outcomes and leads to more “human-like”
  /// preferences (e.g., take a win now instead of later).
  static int _minimaxBest(List<Mark> b, Mark ai) {
    final opp = ai == Mark.X ? Mark.O : Mark.X;

    // Evaluate a terminal position, or return null if not terminal yet.
    int? terminalScore(List<Mark> s, int depth) {
      final w = GameState.checkWinner(s);
      if (w == ai) return 10 - depth;     // prefer quicker wins
      if (w == opp) return depth - 10;    // prefer slower losses (if forced)
      if (GameState.isDraw(s)) return 0;  // draw
      return null;                        // not terminal
    }

    // Core recursive minimax.
    // maximizing == true  -> AI’s turn; choose max score.
    // maximizing == false -> Opponent’s turn; choose min score.
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

    // Loop all legal moves, evaluate with minimax, track the best score,
    // and collect all moves that tie for best. I then select randomly among them
    // so the AI is less predictable when multiple perfect moves exist.
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

    // In a well-formed game state, bestMoves won’t be empty.
    // Fallback to random for safety against unexpected states.
    if (bestMoves.isEmpty) return _randomMove(b);
    return bestMoves[math.Random().nextInt(bestMoves.length)];
  }
}

/// Extension methods on GameState so the UI layer can easily ask the AI for help.
/// I keep these as convenience helpers because they respect in-progress/terminal
/// state and reuse the same API as user moves.
extension GameAI on GameState {
  /// Returns an index suggestion for the current board and difficulty.
  /// If the game is already over, returns null to signal “no move available”.
  int? aiSuggestMove(Difficulty difficulty, {Mark? aiMark}) {
    if (gameOver) return null;
    final mark = aiMark ?? current;
    return TicTacAI.chooseMove(board, mark, difficulty);
  }

  /// Asks the AI to actually make a move:
  /// - Picks a move using the selected difficulty and (optionally) a forced mark.
  /// - Validates the move (defensive programming against stale UIs).
  /// - Calls `playAt` to update state and toggle turns if successful.
  ///
  /// Returns true if a move was played; false if not (game over or invalid).
  bool aiPlay(Difficulty difficulty, {Mark? aiMark}) {
    if (gameOver) return false;
    final mark = aiMark ?? current;
    final idx = TicTacAI.chooseMove(board, mark, difficulty);
    if (!isValidMove(idx)) return false;
    playAt(idx);
    return true;
  }
}
