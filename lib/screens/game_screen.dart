// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import '../game_logic.dart';
import '../ai.dart';
import '../storage.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final game = GameState();
  Difficulty _difficulty = Difficulty.medium;
  late final AnimationController _winCtrl;
  bool _logged = false;

  @override
  void initState() {
    super.initState();
    _winCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _winCtrl.dispose();
    super.dispose();
  }

  void _maybeAnimateWin() {
    if (game.winningLine != null) {
      _winCtrl
        ..reset()
        ..forward();
    } else {
      _winCtrl.reset();
    }
  }

  Future<void> _logIfFinished() async {
    if (game.gameOver && !_logged) {
      final moves = game.board.where((m) => m != Mark.empty).length;
      final winner = (game.winner == Mark.empty) ? null : game.winner;
      await AppStorage.instance.recordGame(winner: winner, moves: moves);
      _logged = true;
    }
  }

  void _tap(int i) {
    if (game.gameOver || game.board[i] != Mark.empty) return;
    setState(() {
      game.playAt(i);
    });
    _maybeAnimateWin();
    _logIfFinished();

    if (!game.gameOver && game.current == Mark.O) {
      setState(() {
        game.aiPlay(_difficulty);
      });
      _maybeAnimateWin();
      _logIfFinished();
    }
  }

  void _undo() {
    setState(() {
      _logged = false;
      game.undoOne();
      if (game.current == Mark.O && !game.gameOver) {
        game.undoOne();
      }
    });
    _maybeAnimateWin();
  }

  void _newGame() {
    setState(() {
      _logged = false;
      game.resetBoard();
    });
    _maybeAnimateWin();
  }

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
      backgroundColor: const Color(0xFF1B1B2F),
      appBar: AppBar(
        title: const Text('Game'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            _status,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Difficulty:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                DropdownButtonHideUnderline(
                  child: DropdownButton<Difficulty>(
                    value: _difficulty,
                    onChanged: (d) => setState(() => _difficulty = d!),
                    dropdownColor: const Color(0xFF2A2A3F),
                    iconEnabledColor: Colors.white,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    items: const [
                      DropdownMenuItem(value: Difficulty.easy, child: Text('Easy')),
                      DropdownMenuItem(value: Difficulty.medium, child: Text('Medium')),
                      DropdownMenuItem(value: Difficulty.hard, child: Text('Hard')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      backgroundColor: scheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _undo,
                    child: const Text('Undo'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _newGame,
                    child: const Text('New Game'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    GridView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 9,
                      itemBuilder: (_, i) {
                        final mark = game.board[i];
                        final disabled = game.gameOver || mark != Mark.empty;
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          onPressed: disabled ? null : () => _tap(i),
                          child: Text(
                            _cell(mark),
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    if (game.winningLine != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _winCtrl,
                            builder: (_, __) => CustomPaint(
                              painter: _WinLinePainter(game.winningLine!, _winCtrl.value),
                              size: Size.infinite,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WinLinePainter extends CustomPainter {
  final List<int> line;
  final double t;
  _WinLinePainter(this.line, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final cellW = size.width / 3;
    final cellH = size.height / 3;

    Offset center(int index) {
      final r = index ~/ 3;
      final c = index % 3;
      return Offset(c * cellW + cellW / 2, r * cellH + cellH / 2);
    }

    final p1 = center(line.first);
    final p2 = center(line.last);
    final current = Offset.lerp(p1, p2, t)!;
    canvas.drawLine(p1, current, shadow);
    canvas.drawLine(p1, current, paint);
  }

  @override
  bool shouldRepaint(covariant _WinLinePainter oldDelegate) => oldDelegate.line != line || oldDelegate.t != t;
}
