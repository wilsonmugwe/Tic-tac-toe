import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/game_logic.dart';

/// Unit tests for state management in GameState:
/// - reset should produce a clean board and defaults
/// - undo should revert the last move and restore the correct turn
/// - undo after a terminal state should clear gameOver/winner/line
/// - once the game is over, further plays must be ignored
/// - edge cases around draining the undo stack and resetting history
void main() {
  group('GameState • state & undo/reset', () {
    test('Reset returns to fresh game', () {
      final g = GameState();

      // Dirty the board a bit so reset actually has something to clear.
      g.playAt(0);
      g.playAt(4);
      g.playAt(8);

      // Reset should wipe the board, reset turn to X, and clear any terminal flags.
      g.resetBoard();
      expect(g.board.where((m) => m == Mark.empty).length, 9);
      expect(g.current, Mark.X);
      expect(g.gameOver, false);
      expect(g.winner, isNull);
      expect(g.winningLine, isNull);
    });

    test('Undo reverts last move and restores turn', () {
      final g = GameState();

      // Two valid moves to populate history: X@0 then O@1.
      g.playAt(0); // X
      g.playAt(1); // O

      // After O moves, it should be X's turn.
      expect(g.current, Mark.X);

      // Undo should pop O@1, restoring the board and giving turn back to O.
      final ok = g.undoOne();
      expect(ok, true);
      expect(g.board[1], Mark.empty);
      expect(g.current, Mark.O);
      expect(g.gameOver, false);
      expect(g.winner, isNull);
      expect(g.winningLine, isNull);
    });

    test('Undo after a win clears gameOver and winner', () {
      final g = GameState();

      // Create a quick win for X on the top row: (0,1,2).
      g.playAt(0); g.playAt(3);
      g.playAt(1); g.playAt(4);
      g.playAt(2); // X wins
      expect(g.gameOver, true);
      expect(g.winner, Mark.X);
      expect(g.winningLine, equals([0, 1, 2]));

      // Undo the winning move; this should clear the terminal state.
      final ok = g.undoOne();
      expect(ok, true);
      expect(g.gameOver, false);
      expect(g.winner, isNull);
      expect(g.winningLine, isNull);
      expect(g.board[2], Mark.empty);
      expect(g.current, Mark.X); // turn restored correctly
    });

    test('Prevents play after game over', () {
      final g = GameState();

      // Force a win, then attempt another move.
      g.playAt(0); g.playAt(3);
      g.playAt(1); g.playAt(4);
      g.playAt(2); // X wins

      // Any further plays must be ignored (no board or turn change).
      final before = List<Mark>.from(g.board);
      final turn   = g.current;
      g.playAt(5); // ignored
      expect(g.board, equals(before));
      expect(g.current, turn);
    });

    test('Undo drains history; then returns false', () {
      final g = GameState();

      // Build up a bit of reversible history.
      g.playAt(0);
      g.playAt(1);
      g.playAt(2);

      // Keep undoing until history is empty.
      while (g.undoOne()) {}

      // One more undo should report false; state must look fresh.
      expect(g.undoOne(), false);
      expect(g.board.where((m) => m == Mark.empty).length, 9);
      expect(g.current, Mark.X);
      expect(g.gameOver, false);
      expect(g.winner, isNull);
      expect(g.winningLine, isNull);
    });

    test('Undo after reset is false', () {
      final g = GameState();

      // Make at least one move, then reset (which should clear history).
      g.playAt(0);
      g.resetBoard();

      // With history cleared, there’s nothing to undo.
      expect(g.undoOne(), false);
    });
  });
}
