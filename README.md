# Tic Tac Toe (Flutter)

A digital version of the classic **Tic Tac Toe** game, built in Flutter.  
The app lets players compete against an AI opponent with three difficulty levels: Easy, Medium, and Hard.  
It also supports undo functionality, persistent score tracking, and a clean, responsive user interface.

---

## Features
- Human vs AI – play against a computer-controlled opponent.
- Difficulty Levels – Easy (random), Medium (blocking & heuristics), Hard (minimax algorithm).
- Undo Moves – revert the last move using a move history stack.
- Persistent Scores – track wins, losses, and draws across sessions using `shared_preferences`.
- Responsive UI – works across devices and screen sizes with Flutter widgets.
- Multiple Screens – Home menu, Game board, and How-to-play instructions.

---

## Project Structure
```plaintext
lib/
├── logic/
│   └── game_state.dart        # Core game rules and state management
├── models/
│   └── score.dart             # Tracks wins, losses, and draws
├── utils.dart                 # Helper functions
├── ai.dart                    # AI difficulty logic (Easy, Medium, Hard)
└── screens/
    ├── home_screen.dart       # Start menu & navigation
    ├── game_screen.dart       # Main 3×3 board and gameplay
    └── howto_screen.dart      # Game instructions


```
---

## Dependencies

```
Key packages used in this project:

- `shared_preferences` – persistent score storage
- `provider` – state management
- `intl` – formatting utilities
- `cupertino_icons` – iOS-style icons
- `flutter_lints` – linting rules for code quality
- `flutter_test` – unit and widget testing

See [`pubspec.yaml`](pubspec.yaml) for exact versions.

```
---

## Getting Started


1. Clone this repository:
   ```
   git clone https://github.com/wilsonmugwe/tictactoe.git
   cd tictactoe

   ```



2. Install dependencies:
    ```
    flutter pub get

    ```

3. Run the app:
    ```
    flutter run

    ```

---

## Testing

Unit tests verify:

Move validation

Win/Draw detection

Undo functionality

AI behaviour (Easy, Medium, Hard)

Run all tests with:

    ```
    flutter test

    ```


---

## How to Play

-The human player is always X.

-The AI is O and will play based on the selected difficulty.

-Get three marks in a row (horizontally, vertically, or diagonally) to win.

-Use Undo if you want to rethink your last move.

-Scores are tracked and saved automatically.


---

## License

This project is for educational purposes as part of the CSP2108 Mobile App Project.


