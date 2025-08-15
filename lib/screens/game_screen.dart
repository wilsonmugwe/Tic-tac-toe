// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import '../game_logic.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final game = GameState();

  void _tap(int i) => setState(() => game.playAt(i));
  void _undo() => setState(() => game.undoOne());
  void _newGame() => setState(() => game.resetBoard());

  String get _status {
    if (game.gameOver) {
      if (game.winner == Mark.X) return 'X wins';
      if (game.winner == Mark.O) return 'O wins';
      return 'Draw';
    }
    return game.current == Mark.X ? 'X to move' : 'O to move';
  }

  String _cell(Mark m) => switch (m) { Mark.X => 'X', Mark.O => 'O', _ => '' };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Game')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text(_status, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black)),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10,
                  ),
                  itemCount: 9,
                  itemBuilder: (_, i) {
                    final mark = game.board[i];
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.85),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: scheme.primary.withOpacity(0.35), width: 1.5),
                      ),
                      onPressed: () => _tap(i),
                      child: Text(
                        _cell(mark),
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonal(onPressed: _undo, child: const Text('Undo')),
                const SizedBox(width: 12),
                FilledButton(onPressed: _newGame, child: const Text('New Game')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
