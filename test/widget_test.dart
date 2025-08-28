import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tictactoe/settings_store.dart';
import 'package:tictactoe/screens/settings_screen.dart';

void main() {
  Widget wrap(Widget child) => ChangeNotifierProvider(
        create: (_) => SettingsStore(),
        child: child,
      );

  testWidgets('Minimal navigator builds', (tester) async {
    await tester.pumpWidget(
      wrap(
        MaterialApp(
          routes: {
            '/settings': (_) => const SettingsScreen(),
          },
          home: const Scaffold(body: Text('home')),
        ),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('Can navigate to /settings route', (tester) async {
    await tester.pumpWidget(
      wrap(
        MaterialApp(
          routes: {
            '/settings': (_) => const SettingsScreen(),
          },
          home: const Scaffold(body: Text('home')),
        ),
      ),
    );

    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.pushNamed('/settings');

    // This should settle quickly since there are no looping animations here.
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
