// lib/screens/stats_screen.dart
import 'package:flutter/material.dart';
import '../storage.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<Stats> _future;

  @override
  void initState() {
    super.initState();
    _future = AppStorage.instance.getStats();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = AppStorage.instance.getStats();
    });
  }

  Future<void> _reset() async {
    await AppStorage.instance.resetStats();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      appBar: AppBar(
        title: const Text('Stats'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          IconButton(icon: const Icon(Icons.restart_alt), onPressed: _reset),
        ],
      ),
      body: FutureBuilder<Stats>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final s = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _StatRow(title: 'Totals', children: [
                  _MetricCard(label: 'Games', value: s.games.toString()),
                  _MetricCard(label: 'X Wins', value: s.xWins.toString()),
                  _MetricCard(label: 'O Wins', value: s.oWins.toString()),
                  _MetricCard(label: 'Draws', value: s.draws.toString()),
                ]),
                const SizedBox(height: 16),
                _StatRow(title: 'Rates', children: [
                  _Gauge(label: 'X Win %', value: s.xWinRate),
                  _Gauge(label: 'O Win %', value: s.oWinRate),
                  _Gauge(label: 'Draw %', value: s.drawRate),
                ]),
                const SizedBox(height: 16),
                _StatRow(title: 'Quality', children: [
                  _MetricCard(label: 'Avg Moves', value: s.avgMoves.toStringAsFixed(1)),
                  _MetricCard(label: 'Last Game', value: s.lastGameAt == null ? '—' : _fmt(s.lastGameAt!)),
                ]),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _reset,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: const Color(0xFF7C4DFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Reset Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}

class _StatRow extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _StatRow({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 12, runSpacing: 12, children: children),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  const _MetricCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252542),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Gauge extends StatelessWidget {
  final String label;
  final double value;
  const _Gauge({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final pct = (value.clamp(0, 1.0) * 100).toStringAsFixed(0);
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252542),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$pct%', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value.clamp(0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C4DFF)),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
