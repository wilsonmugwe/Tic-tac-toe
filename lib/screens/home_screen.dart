// lib/screens/home_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Noughts & Crosses'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFDAD2FF),
                  Color(0xFFBFD1FF),
                  Color(0xFFF0E9FF),
                ],
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _XOPatternPainter())),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _TicTacCard(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.grid_3x3, size: 88, color: Color(0xFF4B2E83)),
                        const SizedBox(height: 18),
                        const Text(
                          'Noughts & Crosses',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Play Tic Tac Toe vs AI with undo and persistent stats.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _MenuButton(
                          icon: Icons.play_arrow_rounded,
                          label: 'Play',
                          onPressed: () => Navigator.pushNamed(context, '/game'),
                          backgroundColor: const Color(0xFF4B2E83),
                          foregroundColor: Colors.white,
                          shadowColor: const Color(0x80321E5C),
                        ),
                        const SizedBox(height: 14),
                        _MenuButton(
                          icon: Icons.bar_chart,
                          label: 'Stats',
                          onPressed: () => Navigator.pushNamed(context, '/stats'),
                          backgroundColor: const Color(0xFF3E345F),
                          foregroundColor: Colors.white,
                          shadowColor: const Color(0x802A2342),
                        ),
                        const SizedBox(height: 14),
                        _MenuButton(
                          icon: Icons.settings,
                          label: 'Settings',
                          onPressed: () => Navigator.pushNamed(context, '/settings'),
                          backgroundColor: const Color(0xFF3E345F),
                          foregroundColor: Colors.white,
                          shadowColor: const Color(0x802A2342),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/howto'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black87,
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          child: const Text('How to Play'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? shadowColor;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.shadowColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      minimumSize: const Size.fromHeight(60),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      shadowColor: shadowColor,
      elevation: 4,
    );

    return FilledButton(
      style: style,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}

class _TicTacCard extends StatelessWidget {
  final Widget child;
  const _TicTacCard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: CustomPaint(
        painter: _TicTacBorderPainter(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 12)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TicTacBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outerRRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(24),
    );

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF5E4FB0).withOpacity(0.6);

    canvas.drawRRect(outerRRect, borderPaint);

    const inset = 14.0;
    final rect = Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2);

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = const Color(0xFF5E4FB0).withOpacity(0.45);

    final vx1 = rect.left + rect.width / 3;
    final vx2 = rect.left + rect.width * 2 / 3;
    canvas.drawLine(Offset(vx1, rect.top), Offset(vx1, rect.bottom), gridPaint);
    canvas.drawLine(Offset(vx2, rect.top), Offset(vx2, rect.bottom), gridPaint);

    final hy1 = rect.top + rect.height / 3;
    final hy2 = rect.top + rect.height * 2 / 3;
    canvas.drawLine(Offset(rect.left, hy1), Offset(rect.right, hy1), gridPaint);
    canvas.drawLine(Offset(rect.left, hy2), Offset(rect.right, hy2), gridPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _XOPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final xoColor = const Color(0xFF2C2A5B).withOpacity(0.07);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = xoColor
      ..strokeCap = StrokeCap.round;

    void drawX(double cx, double cy, double s, double angle) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      final half = s / 2;
      canvas.drawLine(Offset(-half, -half), Offset(half, half), stroke);
      canvas.drawLine(Offset(-half, half), Offset(half, -half), stroke);
      canvas.restore();
    }

    void drawO(double cx, double cy, double r) {
      canvas.drawCircle(Offset(cx, cy), r, stroke);
    }

    drawO(size.width * 0.15, size.height * 0.25, 90);
    drawX(size.width * 0.85, size.height * 0.20, 180, math.pi / 8);
    drawO(size.width * 0.80, size.height * 0.75, 120);
    drawX(size.width * 0.25, size.height * 0.80, 160, -math.pi / 10);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
