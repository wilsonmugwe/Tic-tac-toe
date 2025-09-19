// lib/game_logic.dart
//
// This file contains the core, framework-agnostic game logic for Noughts & Crosses.
// No Flutter UI code lives here—just the rules of the game and a small state
// container that I can unit-test in isolation. The UI (widgets) simply calls into
// this API (e.g., playAt, undoOne, resetBoard) and reacts to the updated state.

/// A single board cell can be empty, 'X', or 'O'.
/// I prefer an enum here for type-safety and readability instead of raw strings.
enum Mark { empty, X, O }

/// Holds the entire game state for a single match:
/// - `board`: a 1D list of 9 cells (indexes 0..8) representing 3x3
/// - `current`: whose turn it is (X goes first by default)
/// - `gameOver`: whether the match has reached a terminal state (win/draw)
/// - `winner`: the result (X, O, empty for draw, or null if still in progress)
/// - `_history`: stack of moves to support undo (simple, predictable)
/// - `_winningCombo`: the winning triplet of indexes, if any (e.g., [0, 4, 8])
///
/// Design notes:
/// - I intentionally keep this class small and deterministic so tests are easy.
/// - All transitions go through a few well-defined methods: `playAt`, `undoOne`,
///   `resetBoard`, and the internal `_updateOutcome`.
class GameState {
  // Board is a flat list to keep indexing simple and fast.
  // Mapping to 2D: row = i ~/ 3, col = i % 3.
  List<Mark> board;

  // Tracks whose turn it is. X moves first by convention.
  Mark current;

  // True once we detect a win or a draw; otherwise false.
  bool gameOver;

  // When `gameOver == true`:
  //   - Mark.X or Mark.O indicates the winner.
  //   - Mark.empty indicates a draw.
  // When the game is still running: `winner == null`.
  Mark? winner;

  // Move history for undo support. Newest move sits at the end of the list.
  final List<_Move> _history;

  // The actual winning line (triplet of indexes) if someone won; null otherwise.
  List<int>? _winningCombo;

  /// Creates a fresh game with an empty board and X to start.
  GameState()
      : board = List.filled(9, Mark.empty),
        current = Mark.X,
        gameOver = false,
        winner = null,
        _history = [],
        _winningCombo = null;

  /// All 8 possible winning lines on a 3x3 board:
  /// - 3 rows, 3 columns, 2 diagonals.
  static const List<List<int>> _lines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // cols
    [0, 4, 8], [2, 4, 6],            // diags
  ];

  /// Exposes the last detected winning line for highlight purposes in the UI.
  List<int>? get winningLine => _winningCombo;

  /// A move is valid if:
  ///  - The game is not already over.
  ///  - The index is within 0..8.
  ///  - The target cell is currently empty.
  bool isValidMove(int i) =>
      !gameOver && i >= 0 && i < 9 && board[i] == Mark.empty;

  /// Attempts to place the current player's mark at index `i`.
  /// If the move is invalid, the call is a no-op.
  /// Otherwise:
  ///   - Write the mark to the board.
  ///   - Push a record to `_history` (for undo).
  ///   - Recompute the outcome (win/draw/in-progress).
  ///   - If still in progress, flip the turn.
  void playAt(int i) {
    if (!isValidMove(i)) return;
    board[i] = current;
    _history.add(_Move(i, current));
    _updateOutcome();
    if (!gameOver) {
      current = (current == Mark.X) ? Mark.O : Mark.X;
    }
  }

  /// Undo exactly one move if possible.
  /// Returns true on success, false if there is nothing to undo.
  ///
  /// Details:
  ///   - Pop the last move from `_history`.
  ///   - Clear that cell back to empty.
  ///   - Restore the `current` player to the mover we just popped.
  ///   - Reset end-state flags so the game continues.
  bool undoOne() {
    if (_history.isEmpty) return false;
    final last = _history.removeLast();
    board[last.i] = Mark.empty;
    current = last.m;
    gameOver = false;
    winner = null;
    _winningCombo = null;
    return true;
    // Note: I don’t try to reconstruct partial win/draw states here because undo
    // is always followed by further user actions or a UI refresh. If needed,
    // I could recompute outcome from scratch after an undo by scanning the board.
  }

  /// Fully resets the match to a clean slate.
  /// Useful for "Play Again" without reconstructing a new GameState instance.
  void resetBoard() {
    board = List.filled(9, Mark.empty);
    current = Mark.X;
    gameOver = false;
    winner = null;
    _winningCombo = null;
    _history.clear();
  }

  /// After every valid move, I call this to determine whether the game finished.
  /// - If I detect a winning line, lock the game and store the winner + combo.
  /// - If there are no empty cells and no winner, declare a draw.
  /// - Otherwise, the game continues.
  void _updateOutcome() {
    final combo = winningCombo(board);
    if (combo != null) {
      gameOver = true;
      winner = board[combo[0]]; // Any index in the combo holds the winner’s mark.
      _winningCombo = combo;
      return;
    }
    if (isDraw(board)) {
      gameOver = true;
      winner = Mark.empty; // I use Mark.empty to represent "draw" terminal state.
      _winningCombo = null;
    }
  }

  /// Computes the winner on an arbitrary board `b`.
  /// Returns:
  ///   - Mark.X or Mark.O if someone has three in a row
  ///   - null if there is no winner yet
  static Mark? checkWinner(List<Mark> b) {
    for (final L in _lines) {
      final a = b[L[0]], c = b[L[1]], d = b[L[2]];
      if (a != Mark.empty && a == c && c == d) {
        return a;
      }
    }
    return null;
  }

  /// Returns the winning line (triplet of indexes) if the board `b` has a winner,
  /// otherwise returns null. This is handy for UI to highlight the line.
  static List<int>? winningCombo(List<Mark> b) {
    for (final L in _lines) {
      final a = b[L[0]], c = b[L[1]], d = b[L[2]];
      if (a != Mark.empty && a == c && c == d) {
        return L;
      }
    }
    return null;
  }

  /// A board is a draw if:
  ///  - No cells are empty, and
  ///  - There is no winner.
  static bool isDraw(List<Mark> b) =>
      !b.contains(Mark.empty) && checkWinner(b) == null;
}

/// Internal move record used by the undo stack.
/// I only store what I need to reverse a move:
///   - `i`: which cell was played
///   - `m`: which mark was placed there
class _Move {
  final int i;
  final Mark m;
  _Move(this.i, this.m);
}
