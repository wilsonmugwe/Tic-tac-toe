import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/game_logic.dart';

void main() {
  group('GameState • winning conditions', () {
    test('Row win (0,1,2) for X', () {
      final g = GameState();
      g.playAt(0); // X
      g.playAt(3); // O
      g.playAt(1); // X
      g.playAt(4); // O
      g.playAt(2); // X wins
      expect(g.gameOver, true);
      expect(g.winner, Mark.X);
      expect(g.winningLine, [0, 1, 2]);
    });

    test('Column win (0,3,6) for O', () {
      final g = GameState();
      g.playAt(1); // X
      g.playAt(0); // O
      g.playAt(2); // X
      g.playAt(3); // O
      g.playAt(4); // X
      g.playAt(6); // O wins
      expect(g.gameOver, true);
      expect(g.winner, Mark.O);
      expect(g.winningLine, [0, 3, 6]);
    });

    test('Diagonal win (0,4,8) for X', () {
      final g = GameState();
      g.playAt(0); // X
      g.playAt(1); // O
      g.playAt(4); // X
      g.playAt(2); // O
      g.playAt(8); // X wins
      expect(g.gameOver, true);
      expect(g.winner, Mark.X);
      expect(g.winningLine, [0, 4, 8]);
    });

    test('Anti-diagonal win (2,4,6) for X', () {
      final g = GameState();
      g.playAt(2); // X
      g.playAt(0); // O
      g.playAt(4); // X
      g.playAt(1); // O
      g.playAt(6); // X wins
      expect(g.gameOver, true);
      expect(g.winner, Mark.X);
      expect(g.winningLine, [2, 4, 6]);
    });

    test('Draw: board full with no winner', () {
      // X O X / X X O / O X O
      final g = GameState();
      g.playAt(0); // X
      g.playAt(1); // O
      g.playAt(2); // X
      g.playAt(5); // O
      g.playAt(3); // X
      g.playAt(6); // O
      g.playAt(4); // X
      g.playAt(8); // O
      g.playAt(7); // X
      expect(g.gameOver, true);
      expect(g.winner, Mark.empty); // draw encoded as empty
      expect(g.winningLine, isNull);
    });
  });
}
