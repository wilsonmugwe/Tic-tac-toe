import 'package:flutter/material.dart';

class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to Play')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Win with three in a row (row, column, diagonal). Tap an empty cell to place your mark. Undo removes the last move. New Game resets the board.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
