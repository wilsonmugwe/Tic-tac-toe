import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/game_logic.dart';

/// Unit tests that exercise all terminal outcomes in GameState:
/// - wins across all rows, columns, and diagonals
/// - draw state when the board is full without a winner
/// - post-terminal behaviour: no further moves should be allowed
void main() {
  group('GameState • winning conditions', () {
    test('Row win (0,1,2) for X', () {
      final g = GameState();

      // Build a top-row win for X.
      g.playAt(0); g.playAt(3);
      g.playAt(1); g.playAt(4);
      g.playAt(2); // X completes the row

      expect(g.gameOver, true);
      expect(g.winner, Mark.X);
      expect(g.winningLine, equals([0, 1, 2]));
    });

    test('Row win (3,4,5) for X', () {
      final g = GameState();

      // Middle row win: (3,4,5) for X.
      g.playAt(3); g.playAt(0);
      g.playAt(4); g.playAt(1);
      g.playAt(5);

      expect(g.gameOver, true);
      expect(g.winner, Mark.X);
      expect(g.winningLine, equals([3, 4, 5]));
    });

    test('Row win (6,7,8) for X', () {
      final g = GameState();

      // Bottom row win: (6,7,8) for X.
      g.playAt(6); g.playAt(0);
      g.playAt(7); g.playAt(1);
      g.playAt(8);

      expect(g.gameOver, true);
      expect(g.winner, Mark.X);
      expect(g.winningLine, equals([6, 7, 8]));
    });

    test('Column win (0,3,6) for O', () {
      final g = GameState();

      // Let O win the first column to confirm both players can win.
      g.playAt(1); g.playAt(0);
      g.playAt(2); g.playAt(3);
      g.playAt(4); g.playAt(6); // O completes the column

      expect(g.gameOver, true);
      expect(g.winner, Mark.O);
      expect(g.winningLine, equals([0, 3, 6]));
    });

    test('Column win (1,4,7) for X', () {
      final g = GameState();

      // Middle column win: (1,4,7) for X.
      g.playAt(1); g.playAt(0);
      g.playAt(4); g.playAt(3);
      g.playAt(7);

      expect(g.gameOver, true);
      expect(g.winner, Mark.X);
      expect(g.winningLine, equals([1, 4, 7]));
    });

    test('Column win (2,5,8) for X', () {
      final g = GameState();

      // Right column win: (2,5,8) for X.
      g.playAt(2); g.playAt(0);
      g.playAt(5); g.playAt(3);
      g.playAt(8);

      expect(g.gameOver, true);
      expect(g.winner, Mark.X);
      expect(g.winningLine, equals([2, 5, 8]));
    });

    test('Diagonal win (0,4,8) for X', () {
      final g = GameState();

      // Main diagonal win from top-left to bottom-right.
      g.playAt(0); g.playAt(1);
      g.playAt(4); g.playAt(2);
      g.playAt(8); // X completes diagonal

      expect(g.gameOver, true);
      expect(g.winner, Mark.X);
      expect(g.winningLine, equals([0, 4, 8]));
    });

    test('Anti-diagonal win (2,4,6) for X', () {
      final g = GameState();

      // Anti-diagonal win from top-right to bottom-left.
      g.playAt(2); g.playAt(0);
      g.playAt(4); g.playAt(1);
      g.playAt(6); // X completes anti-diagonal

      expect(g.gameOver, true);
      expect(g.winner, Mark.X);
      expect(g.winningLine, equals([2, 4, 6]));
    });

    test('Draw: board full with no winner', () {
      final g = GameState();

      // Fill the board to produce a draw:
      // X O X
      // X X O
      // O X O
      g.playAt(0); g.playAt(1);
      g.playAt(2); g.playAt(5);
      g.playAt(3); g.playAt(6);
      g.playAt(4); g.playAt(8);
      g.playAt(7);

      expect(g.gameOver, true);
      expect(g.winner, Mark.empty); // model uses Mark.empty to represent a draw
      expect(g.winningLine, isNull);
    });

    test('No moves valid after a win', () {
      final g = GameState();

      // Create a win then confirm the board is locked.
      g.playAt(0); g.playAt(3);
      g.playAt(1); g.playAt(4);
      g.playAt(2); // terminal state reached

      for (var i = 0; i < 9; i++) {
        expect(g.isValidMove(i), false, reason: 'No moves valid after win');
      }
    });

    test('No moves valid after a draw', () {
      final g = GameState();

      // Reach a draw and ensure the board is fully locked.
      // X O X
      // X X O
      // O X O
      g.playAt(0); g.playAt(1);
      g.playAt(2); g.playAt(5);
      g.playAt(3); g.playAt(6);
      g.playAt(4); g.playAt(8);
      g.playAt(7);

      for (var i = 0; i < 9; i++) {
        expect(g.isValidMove(i), false, reason: 'No moves valid after draw');
      }
    });
  });
}
