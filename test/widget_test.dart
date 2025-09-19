import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/screens/home_screen.dart';

/// Widget smoke test for the app’s entry screen.
/// Goal: make sure the HomeScreen mounts without errors and shows the primary call-to-action.
/// Notes:
///  - Keep this lightweight. I only want a fast sanity check here.
///  - Copy is allowed to change later, so I’m asserting on partial text ("Play") instead of exact labels.
void main() {
  testWidgets('Home screen renders', (tester) async {
    // Minimal shell – no routes or themes here. Just mount HomeScreen directly.
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // If the widget tree builds correctly, I should find exactly one HomeScreen.
    expect(find.byType(HomeScreen), findsOneWidget);

    // CTA presence: the Play button/text should exist somewhere on the screen.
    // Using textContaining to stay resilient to small copy tweaks (e.g., "Play", "Play Now", etc.).
    expect(find.textContaining('Play'), findsWidgets);
  });
}

