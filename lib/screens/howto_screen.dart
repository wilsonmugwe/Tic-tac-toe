// lib/screens/howto_screen.dart
//
// This screen is a static instructional page. Its job is to quickly teach new
// players the rules of Tic Tac Toe, explain how my app differs (undo, stats, etc.),
// and provide one or two strategic hints.
//
// Design notes:
// - Kept very simple: an AppBar + scrollable text.
// - Content is embedded as a multiline string so there’s no dependency on assets.
// - Text is large enough and spaced for easy readability on small screens.

import 'package:flutter/material.dart';

class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Standard AppBar so navigation back is obvious.
      appBar: AppBar(title: const Text('How to Play')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          // Wrapping text in a scroll view so it remains usable on small screens.
          child: Text(
            '''
Welcome to Tic Tac Toe!

Goal:
Be the first player to get three of your marks in a row. 
This can be across a row, down a column, or diagonally.

How to Play:
1. The game is played on a 3×3 grid.
2. Player X always goes first, followed by Player O.
3. Tap an empty square to place your mark.
4. The game ends when one player gets three in a row or all squares are filled.

Extra Features:
• Undo – Remove the last move if you want to rethink your choice.  
• New Game – Reset the board anytime to start fresh.  
• Score Tracking – Your wins, losses, and ties are counted.  

Tip:
Think ahead and try to block your opponent while creating chances to win.
            ''',
            style: TextStyle(
              fontSize: 18,
              height: 1.5, // generous line spacing for readability
            ),
          ),
        ),
      ),
    );
  }
}
