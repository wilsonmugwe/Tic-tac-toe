// lib/game_logic.dart 
enum Mark { empty, X, O }

class GameState {
  List<Mark> board;
  Mark current;
  bool gameOver;
  Mark? winner;
  final List<_Move> _history;
  List<int>? _winningCombo;

  GameState()
      : board = List.filled(9, Mark.empty),
        current = Mark.X,
        gameOver = false,
        winner = null,
        _history = [],
        _winningCombo = null;

  static const List<List<int>> _lines = [
    [0,1,2],[3,4,5],[6,7,8],
    [0,3,6],[1,4,7],[2,5,8],
    [0,4,8],[2,4,6],
  ];

  List<int>? get winningLine => _winningCombo;

  bool isValidMove(int i) =>
      !gameOver && i >= 0 && i < 9 && board[i] == Mark.empty;

  void playAt(int i) {
    if (!isValidMove(i)) return;
    board[i] = current;
    _history.add(_Move(i, current));
    _updateOutcome();
    if (!gameOver) current = (current == Mark.X) ? Mark.O : Mark.X;
  }

  bool undoOne() {
    if (_history.isEmpty) return false;
    final last = _history.removeLast();
    board[last.i] = Mark.empty;
    current = last.m;
    gameOver = false;
    winner = null;
    _winningCombo = null;
    return true;
  }

  void resetBoard() {
    board = List.filled(9, Mark.empty);
    current = Mark.X;
    gameOver = false;
    winner = null;
    _winningCombo = null;
    _history.clear();
  }

  void _updateOutcome() {
    final combo = winningCombo(board);
    if (combo != null) {
      gameOver = true;
      winner = board[combo[0]];
      _winningCombo = combo;
      return;
    }
    if (isDraw(board)) {
      gameOver = true;
      winner = Mark.empty;
      _winningCombo = null;
    }
  }

  static Mark? checkWinner(List<Mark> b) {
    for (final L in _lines) {
      final a = b[L[0]], c = b[L[1]], d = b[L[2]];
      if (a != Mark.empty && a == c && c == d) return a;
    }
    return null;
  }

  static List<int>? winningCombo(List<Mark> b) {
    for (final L in _lines) {
      final a = b[L[0]], c = b[L[1]], d = b[L[2]];
      if (a != Mark.empty && a == c && c == d) return L;
    }
    return null;
  }

  static bool isDraw(List<Mark> b) =>
      !b.contains(Mark.empty) && checkWinner(b) == null;
}

class _Move {
  final int i; final Mark m;
  _Move(this.i, this.m);
}
