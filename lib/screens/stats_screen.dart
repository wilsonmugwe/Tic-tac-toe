// lib/screens/stats_screen.dart
//
// This screen displays my persistent gameplay stats (games played, X/O wins, draws)
// and provides a single call-to-action to reset everything. The data source is
// AppStorage (SharedPreferences under the hood), which returns a Stats model.
//
// Design goals:
// - Keep the layout very legible on both phones and larger screens.
// - Avoid jitter: load stats once via FutureBuilder and render a stable UI.
// - Make “Reset Stats” an explicit, confirmed action so it’s hard to do by accident.

import 'package:flutter/material.dart';
import '../storage.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  // I hold a Future so the build can render a spinner while stats load,
  // and I can refresh it after a reset.
  late Future<Stats> _future;

  @override
  void initState() {
    super.initState();
    // Initial load of stats from local storage.
    _future = AppStorage.instance.getStats();
  }

  /// Ask the user to confirm, then clear stats and refresh the FutureBuilder.
  Future<void> _resetStats() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reset Stats"),
        content: const Text("Are you sure you want to reset all stats?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Reset"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AppStorage.instance.resetStats();
      // Re-trigger FutureBuilder by assigning a new future.
      setState(() {
        _future = AppStorage.instance.getStats();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Layered background: dark gradient with faint XO icons for texture.
      body: Stack(
        children: [
          const _DarkBackground(),
          SafeArea(
            child: Column(
              children: [
                // Back button only (no big AppBar) to keep the page focused.
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
                const SizedBox(height: 8),

                // Page title.
                const Text(
                  'Stats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Main content area: waits for the stats Future to complete.
                Expanded(
                  child: FutureBuilder<Stats>(
                    future: _future,
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final s = snap.data!;

                      // Avoid divide-by-zero by substituting 1 when total is zero.
                      final total = s.games > 0 ? s.games : 1;
                      final xPct = ((s.xWins / total) * 100).toStringAsFixed(1);
                      final oPct = ((s.oWins / total) * 100).toStringAsFixed(1);
                      final dPct = ((s.draws / total) * 100).toStringAsFixed(1);

                      // Simple, centered layout: one full-width card + three equal cards.
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _StatCard(
                              label: "Games Played",
                              value: s.games.toString(),
                              fullWidth: true,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    label: "X Wins",
                                    value: "${s.xWins} ($xPct%)",
                                    fixedHeight: 130,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: _StatCard(
                                    label: "O Wins",
                                    value: "${s.oWins} ($oPct%)",
                                    fixedHeight: 130,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: _StatCard(
                                    label: "Draws",
                                    value: "${s.draws} ($dPct%)",
                                    fixedHeight: 130,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Destructive action: visually prominent but separated at the bottom.
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: SizedBox(
                    width: 320,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        backgroundColor: const Color(0xFF7C4DFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        elevation: 10,
                      ),
                      onPressed: _resetStats,
                      child: const Text(
                        'Reset Stats',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable card widget for a single stat value + label.
/// I keep the text styles consistent across all instances and allow
/// optional full-width or fixed-height variants for layout control.
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool fullWidth;
  final double? fixedHeight;

  const _StatCard({
    required this.label,
    required this.value,
    this.fullWidth = false,
    this.fixedHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      height: fixedHeight,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Primary stat value (large, bold, centered).
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
          const SizedBox(height: 6),
          // Secondary label for context.
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Background painter layer for the Stats screen.
/// Simple dark gradient plus faint XO icons to tie the visuals back to the game.
class _DarkBackground extends StatelessWidget {
  const _DarkBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0F0F), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            top: 60,
            left: -40,
            child: Icon(Icons.circle_outlined, size: 200, color: Colors.white12),
          ),
          Positioned(
            bottom: 80,
            right: -30,
            child: Icon(Icons.close, size: 240, color: Colors.white12),
          ),
        ],
      ),
    );
  }
}
