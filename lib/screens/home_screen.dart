// lib/screens/home_screen.dart
//
// This is the app’s landing page. The goal here is to make a strong first impression:
// a light animated XO logo, a soft gradient background with subtle XO flourishes,
// and three primary actions (Play, Stats, How to Play).
//
// Design notes:
// - I keep the visuals self-contained in a few private widgets/painters so the build()
//   method reads like a layout rather than a paint routine.
// - The only state I manage locally is the slow rotation for the logo animation.
// - Buttons route via named routes so navigation is decoupled from concrete widget types.

import 'dart:math' as math;
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// I use a SingleTickerProviderStateMixin to drive a simple rotation animation on the logo.
/// No business state lives here; this is purely presentational.
class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    // A very slow, continuous rotation for the logo icon.
    // The AnimationController loops every 16s to keep motion calm and non-distracting.
    _spin = AnimationController(vsync: this, duration: const Duration(seconds: 16))
      ..repeat();
  }

  @override
  void dispose() {
    // Always dispose animation controllers to avoid leaks.
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        // I keep the AppBar visually minimal on the home screen.
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Noughts & Crosses'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background layers: a gentle gradient + sparse XO pattern strokes.
          const _BackgroundGradient(),
          Positioned.fill(child: CustomPaint(painter: _XOPatternPainter())),
          // Foreground content is padded inside SafeArea and centered with a max width.
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated XO logo: small rotation driven by _spin value.
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: AnimatedBuilder(
                              animation: _spin,
                              builder: (context, _) {
                                // Convert the controller's 0..1 to radians, then dampen the rotation.
                                final angle = (_spin.value * 2 * math.pi) * 0.05;
                                return Transform.rotate(
                                  angle: angle,
                                  child: const _LogoXO(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Title block: bold, large, centered. I keep this as text, not an image,
                          // to respect user font settings and keep it crisp on all DPIs.
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
                          // Short, concrete value proposition for the app.
                          const Text(
                            'Play Tic Tac Toe vs AI with undo and persistent stats.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.black87),
                          ),
                          const SizedBox(height: 28),

                          // Primary call-to-action: Play.
                          _MenuButton(
                            icon: Icons.play_arrow_rounded,
                            label: 'Play',
                            onPressed: () => Navigator.pushNamed(context, '/game'),
                            backgroundColor: const Color(0xFF4B2E83),
                            foregroundColor: Colors.white,
                            shadowColor: const Color(0x80321E5C),
                          ),
                          const SizedBox(height: 14),

                          // Secondary CTA: Stats.
                          _MenuButton(
                            icon: Icons.bar_chart_rounded,
                            label: 'Stats',
                            onPressed: () => Navigator.pushNamed(context, '/stats'),
                            backgroundColor: const Color(0xFF3E345F),
                            foregroundColor: Colors.white,
                            shadowColor: const Color(0x802A2342),
                          ),

                          const SizedBox(height: 14),

                          // Secondary CTA: How to Play.
                          _MenuButton(
                            icon: Icons.help_outline_rounded,
                            label: 'How to Play',
                            onPressed: () => Navigator.pushNamed(context, '/howto'),
                            backgroundColor: const Color(0xFF3E345F),
                            foregroundColor: Colors.white,
                            shadowColor: const Color(0x802A2342),
                          ),

                          const SizedBox(height: 12),

                          // App version. Kept subtle to avoid visual noise.
                          Text(
                            'v1.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurface.withOpacity(0.45),
                            ),
                          ),
                        ],
                      ),
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

/// Reusable filled button with consistent shape/spacing/typography.
/// I pass colors in from the callsite so the same component can render
/// primary and secondary actions without introducing an entire theming system here.
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

/// Small logo composed of a stroked O and a rotated X.
/// I draw this with CustomPaint so it stays sharp and scales without assets.
class _LogoXO extends StatelessWidget {
  const _LogoXO();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LogoPainter(),
      size: const Size.square(100),
    );
  }
}

/// Painter for the XO mark used in the logo.
/// I intentionally set stroke widths and sizes as percentages of the canvas
/// so the graphic remains balanced at different sizes.
class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final oPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = const Color(0xFF4B2E83);

    final xPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = const Color(0xFF7C4DFF);

    // Circle (O)
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.32;
    canvas.drawCircle(center, r, oPaint);

    // Rotated cross (X)
    final s = size.width * 0.55;
    final half = s / 2;
    final angle = math.pi / 8;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawLine(Offset(-half, -half), Offset(half, half), xPaint);
    canvas.drawLine(Offset(-half, half), Offset(half, -half), xPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Background layer: soft multi-stop gradient.
/// I keep color choices mild to let the card and buttons carry the visual weight.
class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDAD2FF), Color(0xFFBFD1FF), Color(0xFFF0E9FF)],
        ),
      ),
    );
  }
}

/// A translucent card with rounded corners and a soft shadow.
/// I use ClipRRect to ensure the child content respects the rounded edges.
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Painter for a sparse XO pattern behind the content.
/// The low opacity and large strokes keep it decorative without stealing focus.
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

    // I keep the elements few and oversized so they read as background texture.
    drawO(size.width * 0.15, size.height * 0.25, 90);
    drawX(size.width * 0.85, size.height * 0.20, 180, math.pi / 8);
    drawO(size.width * 0.80, size.height * 0.75, 120);
    drawX(size.width * 0.25, size.height * 0.80, 160, -math.pi / 10);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
