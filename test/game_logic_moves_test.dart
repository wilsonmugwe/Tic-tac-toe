import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/game_logic.dart';

void main() {
  group('GameState • move validation', () {
    test('Initial state & turn flipping', () {
      final g = GameState();
      expect(g.current, Mark.X);
      expect(g.isValidMove(0), true);
      g.playAt(0);
      expect(g.board[0], Mark.X);
      expect(g.current, Mark.O); // flipped
    });

    test('Rejects out-of-range and occupied', () {
      final g = GameState();
      expect(g.isValidMove(-1), false);
      expect(g.isValidMove(9), false);
      g.playAt(0); // X takes 0
      expect(g.isValidMove(0), false); // occupied
      // Invalid playAt should not change anything:
      g.playAt(0);
      expect(g.board[0], Mark.X);
      expect(g.current, Mark.O); // still O (no flip on invalid)
    });

    test('No moves allowed after game over', () {
      final g = GameState();
      g.playAt(0); g.playAt(3);
      g.playAt(1); g.playAt(4);
      g.playAt(2); // X wins
      expect(g.gameOver, true);
      final before = List<Mark>.from(g.board);
      g.playAt(5); // should be ignored
      expect(g.board, before);
    });
  });
}
