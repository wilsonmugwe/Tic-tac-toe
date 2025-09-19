// lib/screens/game_screen.dart
//
// This screen hosts the actual match UI and orchestrates interactions between:
//   - GameState (pure rules + state transitions)
//   - AI (easy/medium/hard move selection)
//   - Storage (logging results and moves count for stats)
//
// UX goals:
// - Minimal chrome on top; the board is the hero.
// - Clear status line (“X to move”, “O wins”, “Draw”) with strong, readable type.
// - One-tap actions for Undo and New Game.
// - Smooth, subtle win-line animation for polish.
//
// Implementation notes:
// - I keep a single GameState instance per screen lifetime.
// - I only call setState() around atomic game transitions to keep rebuilds cheap.
// - Results are logged once per game via AppStorage (guarded by `_logged`).
// - If player is X and AI is O, I auto-trigger AI moves immediately after user taps.

import 'package:flutter/material.dart';
import '../game_logic.dart';
import '../ai.dart';
import '../storage.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

/// I use SingleTickerProviderStateMixin to drive the short “win line” animation.
class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  // Core model for the game rules and board state.
  final game = GameState();

  // Default difficulty. I keep it local to this screen for now; if I later
  // add a Settings screen, I’ll persist this value in AppState/SharedPreferences.
  Difficulty _difficulty = Difficulty.medium;

  // Animates the win line from start cell to end cell.
  late final AnimationController _winCtrl;

  // When a game ends, I log once to storage (winner + total moves).
  bool _logged = false;

  @override
  void initState() {
    super.initState();
    _winCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _winCtrl.dispose();
    super.dispose();
  }

  /// Starts (or resets) the win-line animation depending on current state.
  /// I call this after any move that could have ended the game.
  void _maybeAnimateWin() {
    if (game.winningLine != null) {
      _winCtrl
        ..reset()
        ..forward();
    } else {
      _winCtrl.reset();
    }
  }

  /// If the game has reached a terminal state and I haven’t written stats yet,
  /// record the outcome with total moves. I store draws with `winner=null`.
  Future<void> _logIfFinished() async {
    if (game.gameOver && !_logged) {
      final moves = game.board.where((m) => m != Mark.empty).length;
      final winner = (game.winner == Mark.empty) ? null : game.winner;
      await AppStorage.instance.recordGame(winner: winner, moves: moves);
      _logged = true;
    }
  }

  /// Handles a user tapping a cell:
  /// 1) If legal, place player mark.
  /// 2) Animate/log if game ended.
  /// 3) If still running and AI’s turn, ask AI to move and repeat checks.
  void _tap(int i) {
    if (game.gameOver || game.board[i] != Mark.empty) return;

    setState(() {
      game.playAt(i);
    });
    _maybeAnimateWin();
    _logIfFinished();

    // If AI is O by convention (current becomes O after X plays), let it reply.
    if (!game.gameOver && game.current == Mark.O) {
      setState(() {
        game.aiPlay(_difficulty);
      });
      _maybeAnimateWin();
      _logIfFinished();
    }
  }

  /// Undo last action(s).
  /// - Always undo once (the player’s move).
  /// - If it’s AI’s turn and the game isn’t over, undo again to roll back the
  ///   AI’s automatic reply, effectively stepping back a full “round”.
  void _undo() {
    setState(() {
      _logged = false; // allow re-logging once the game re-finishes
      game.undoOne();
      if (game.current == Mark.O && !game.gameOver) {
        game.undoOne();
      }
    });
    _maybeAnimateWin();
  }

  /// Reset the board and clear the logged flag so the next finish is recorded.
  void _newGame() {
    setState(() {
      _logged = false;
      game.resetBoard();
    });
    _maybeAnimateWin();
  }

  /// Human-readable status string for the header.
  String get _status {
    if (game.gameOver) {
      if (game.winner == Mark.X) return 'X wins';
      if (game.winner == Mark.O) return 'O wins';
      return 'Draw';
    }
    return game.current == Mark.X ? 'X to move' : 'O to move';
  }

  /// Render helper: convert a Mark to text.
  String _cell(Mark m) => switch (m) { Mark.X => 'X', Mark.O => 'O', _ => '' };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Full-screen backdrop: deep gradient to make the board pop.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF241B5B), Color(0xFF0F1730)], // deep purple -> midnight blue
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Minimal top row with a back button; I omit a big AppBar title to keep focus on the board.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.maybePop(context),
                      tooltip: 'Back',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Prominent status line to show turns and outcomes.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Difficulty selector. I keep this local to the screen for now.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Difficulty:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<Difficulty>(
                        value: _difficulty,
                        onChanged: (d) => setState(() => _difficulty = d!),
                        dropdownColor: const Color(0xFF2A2A3F),
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
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

              const SizedBox(height: 14),

              // Action row (Undo / New Game). Constrained width keeps them tidy on large screens.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: _GradientButton(
                        label: 'Undo',
                        onPressed: _undo,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: _GradientButton(
                        label: 'New Game',
                        onPressed: _newGame,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // The board: responsive square with a subtle glow behind it.
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        // Soft radial glow to lift the board visually off the background.
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment.center,
                                  radius: 0.8,
                                  colors: [
                                    const Color(0xFF6A5AE0).withOpacity(0.20),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 3x3 grid of big tappable cells.
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
                                backgroundColor: Colors.white.withOpacity(0.10),
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shadowColor: Colors.black.withOpacity(0.35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.40),
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

                        // Win-line overlay: animated stroke drawn from first to last cell in the line.
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
        ),
      ),
    );
  }
}

/// Gradient pill button with soft shadow and hover/tap feedback.
/// I keep the ripple and layout stable by layering the label with a helper (see extension below).
class _GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  const _GradientButton({required this.label, required this.onPressed});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gradNormal = const LinearGradient(
      colors: [Color(0xFF7C5CFF), Color(0xFF5B7BFF)], // purple -> blue
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final gradHover = const LinearGradient(
      colors: [Color(0xFF8B6CFF), Color(0xFF6A8BFF)], // slight shift on hover
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.98 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            gradient: _hover ? gradHover : gradNormal,
            borderRadius: BorderRadius.circular(28), // pill shape
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF000000).withOpacity(0.35),
                offset: const Offset(0, 8),
                blurRadius: 18,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onHighlightChanged: (v) => setState(() => _pressed = v),
              onTap: widget.onPressed,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 22),
                child: Center(
                  child: Text(
                    '',
                    style: TextStyle(), // placeholder; replaced below by overlay label
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    )._withLabel(widget.label);
  }
}

// Small helper to overlay the label while keeping the ripple layout intact.
extension on Widget {
  Widget _withLabel(String label) {
    return Stack(
      alignment: Alignment.center,
      children: [
        this,
        IgnorePointer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints the animated win line across the winning triplet of cells.
/// `t` goes from 0..1, and I lerp from the first cell center toward the last.
/// I also draw a soft shadow stroke behind for depth on dark backgrounds.
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
  bool shouldRepaint(covariant _WinLinePainter oldDelegate) =>
      oldDelegate.line != line || oldDelegate.t != t;
}
