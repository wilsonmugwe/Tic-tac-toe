import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/game_logic.dart';

void main() {
  group('GameState • state & undo/reset', () {
    test('Reset returns to fresh game', () {
      final g = GameState();
      g.playAt(0); g.playAt(4); g.playAt(8);
      g.resetBoard();
      expect(g.board.where((m) => m == Mark.empty).length, 9);
      expect(g.current, Mark.X);
      expect(g.gameOver, false);
      expect(g.winner, isNull);
      expect(g.winningLine, isNull);
    });

    test('Undo reverts last move and restores turn', () {
      final g = GameState();
      g.playAt(0); // X
      g.playAt(1); // O
      expect(g.current, Mark.X); // after O moved
      final ok = g.undoOne();
      expect(ok, true);
      expect(g.board[1], Mark.empty);
      expect(g.current, Mark.O); // last.m restored
      expect(g.gameOver, false);
      expect(g.winner, isNull);
      expect(g.winningLine, isNull);
    });

    test('Undo after a win clears gameOver and winner', () {
      final g = GameState();
      g.playAt(0); g.playAt(3);
      g.playAt(1); g.playAt(4);
      g.playAt(2); // X wins
      expect(g.gameOver, true);
      expect(g.winner, Mark.X);
      expect(g.winningLine, [0,1,2]);

      final ok = g.undoOne(); // remove last X
      expect(ok, true);
      expect(g.gameOver, false);
      expect(g.winner, isNull);
      expect(g.winningLine, isNull);
      expect(g.board[2], Mark.empty);
      expect(g.current, Mark.X); // last move was X, so X to move again
    });
  });

  group('Static helpers', () {
    test('checkWinner / winningCombo / isDraw work on raw boards', () {
      // X wins row 0
      final b1 = <Mark>[
        Mark.X, Mark.X, Mark.X,
        Mark.empty, Mark.O, Mark.empty,
        Mark.empty, Mark.O, Mark.empty,
      ];
      expect(GameState.checkWinner(b1), Mark.X);
      expect(GameState.winningCombo(b1), [0,1,2]);
      expect(GameState.isDraw(b1), false);

      // Full draw
      final b2 = <Mark>[
        Mark.X, Mark.O, Mark.X,
        Mark.X, Mark.X, Mark.O,
        Mark.O, Mark.X, Mark.O,
      ];
      expect(GameState.checkWinner(b2), isNull);
      expect(GameState.winningCombo(b2), isNull);
      expect(GameState.isDraw(b2), true);
    });
  });
}
