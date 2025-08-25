// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ai.dart';                // for Difficulty
import '../settings_store.dart';   // your ChangeNotifier

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SettingsStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader('Gameplay'),
          ListTile(
            title: const Text('AI difficulty'),
            subtitle: Text(_difficultyLabel(store.difficulty)),
            trailing: DropdownButton<Difficulty>(
              value: store.difficulty,
              onChanged: (d) => d != null ? store.setDifficulty(d) : null,
              items: Difficulty.values.map((d) {
                return DropdownMenuItem(
                  value: d,
                  child: Text(_difficultyLabel(d)),
                );
              }).toList(),
            ),
          ),
          SwitchListTile(
            title: const Text('Allow undo'),
            value: store.undoEnabled,
            onChanged: store.setUndoEnabled,
          ),
          const Divider(height: 24),

          _SectionHeader('Feedback'),
          SwitchListTile(
            title: const Text('Sound effects'),
            value: store.soundOn,
            onChanged: store.setSoundOn,
          ),
          SwitchListTile(
            title: const Text('Haptics / vibration'),
            value: store.hapticsOn,
            onChanged: store.setHapticsOn,
          ),
          const Divider(height: 24),

          _SectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark theme'),
            value: store.darkMode,
            onChanged: store.setDarkMode,
          ),
          const Divider(height: 24),

          _SectionHeader('Data'),
          ListTile(
            title: const Text('Reset statistics'),
            subtitle: const Text('Wins, losses, draws, streaks'),
            leading: const Icon(Icons.restart_alt),
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset statistics?'),
                  content: const Text(
                    'This will clear all saved scores and streaks. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    FilledButton.tonal(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await store.resetStats();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Statistics reset')),
                  );
                }
              }
            },
          ),
          const Divider(height: 24),

          _SectionHeader('About'),
          ListTile(
            title: const Text('About this app'),
            leading: const Icon(Icons.info_outline),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Tic Tac Toe',
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(),
                children: const [
                  SizedBox(height: 8),
                  Text('A clean, fast noughts & crosses with AI difficulty levels.'),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  static String _difficultyLabel(Difficulty d) {
    switch (d) {
      case Difficulty.easy: return 'Easy';
      case Difficulty.medium: return 'Medium';
      case Difficulty.hard: return 'Hard';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
