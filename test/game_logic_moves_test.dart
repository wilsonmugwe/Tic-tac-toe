import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/game_logic.dart';

/// Unit tests focused on basic move validation rules of GameState.
/// This file checks:
///  - initial state behavior
///  - how turns alternate after a valid move
///  - rejection of out-of-range and occupied moves
///  - ensuring invalid moves do not alter board or turn
///  - correctness of isValidMove for empty vs occupied cells

void main() {
  group('GameState • move validation', () {
    test('Initial state & turn flipping', () {
      final g = GameState();

      // At the start of the game, X should always go first.
      expect(g.current, Mark.X);

      // Position 0 should be empty and therefore valid.
      expect(g.isValidMove(0), true);

      // X plays in position 0.
      g.playAt(0);

      // That square should now hold an X.
      expect(g.board[0], Mark.X);

      // Turn should flip to O automatically.
      expect(g.current, Mark.O);
    });

    test('Rejects out-of-range and occupied', () {
      final g = GameState();

      // Any index outside 0–8 must be invalid.
      expect(g.isValidMove(-1), false);
      expect(g.isValidMove(9), false);

      // First valid move: X claims index 0.
      g.playAt(0);

      // That cell is no longer valid because it’s occupied.
      expect(g.isValidMove(0), false);

      // Trying to play again on an occupied cell should not change anything.
      final snapshot = List<Mark>.from(g.board);
      final turnBefore = g.current;
      g.playAt(0); // attempt on already occupied spot
      expect(g.board, equals(snapshot));
      expect(g.current, turnBefore);
    });

    test('playAt(out-of-range) is a no-op (no board/turn change)', () {
      final g = GameState();

      // A couple of valid moves to set up some state.
      g.playAt(0); // X
      g.playAt(1); // O

      // Snapshot before invalid moves.
      final before = List<Mark>.from(g.board);
      final turn   = g.current;

      // Try to play outside the 0–8 range. These should be ignored.
      g.playAt(-1);
      g.playAt(9);

      // Board and turn should remain unchanged.
      expect(g.board, equals(before));
      expect(g.current, turn);
    });

    test('isValidMove is true only for empty cells', () {
      final g = GameState();

      // Fill three cells: X(0), O(4), X(8).
      g.playAt(0);
      g.playAt(4);
      g.playAt(8);

      // These cells are taken, so they must return false.
      expect(g.isValidMove(0), false);
      expect(g.isValidMove(4), false);
      expect(g.isValidMove(8), false);

      // Empty cells should still return true.
      expect(g.isValidMove(1), true);
      expect(g.isValidMove(3), true);
    });
  });
}
