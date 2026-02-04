import 'package:flutter/foundation.dart';

import 'package:magicful_2048/models/game_board.dart';
import 'package:magicful_2048/models/tile.dart';
import 'package:magicful_2048/utils/constants.dart';
import 'package:magicful_2048/services/leaderboard_service.dart';
import 'package:magicful_2048/services/user_service.dart';

enum MagicSelectionMode { none, doubleTile, swapFirst, swapSecond, removeTile }

class GameProvider extends ChangeNotifier {
  GameBoard _board = GameBoard();
  GameBoard? _previousBoard;
  int _bestScore = 0;
  int _gridSize = GameSizes.defaultGridSize;

  // Magic abilities - unlimited uses but cost score
  MagicSelectionMode _selectionMode = MagicSelectionMode.none;
  Tile? _firstSwapTile;

  GameBoard get board => _board;
  int get score => _board.score;
  int get bestScore => _bestScore;
  int get gridSize => _gridSize;
  GameState get state => _board.state;

  MagicSelectionMode get selectionMode => _selectionMode;
  Tile? get firstSwapTile => _firstSwapTile;

  bool get canRegenerate => _board.lastAddedTile != null && _board.score >= MagicCosts.regenerate;
  bool get canDouble => _board.score >= MagicCosts.doubleTile;
  bool get canSwap => _board.score >= MagicCosts.swapTiles;
  bool get canRemove => _board.score >= MagicCosts.removeTile && _board.tiles.length > 1;
  bool get canUndo => _previousBoard != null;

  bool get isRankingEligible => _gridSize == GameSizes.rankingGridSize;

  GameProvider() {
    startNewGame();
  }

  void setGridSize(int size) {
    if (GameSizes.availableGridSizes.contains(size)) {
      _gridSize = size;
      notifyListeners();
    }
  }

  void startNewGame() {
    _board = GameBoard(gridSize: _gridSize).initialize(size: _gridSize);
    _previousBoard = null;
    _selectionMode = MagicSelectionMode.none;
    _firstSwapTile = null;
    notifyListeners();
  }

  void move(MoveDirection direction) {
    if (_selectionMode != MagicSelectionMode.none) {
      cancelMagicSelection();
    }

    final newBoard = _board.move(direction);
    if (newBoard != _board) {
      _previousBoard = _board;
      _board = newBoard;
      if (_board.score > _bestScore) {
        _bestScore = _board.score;
      }
      notifyListeners();
    }
  }

  // Free: Undo last move
  void undo() {
    if (!canUndo) return;
    _board = _previousBoard!;
    _previousBoard = null;
    notifyListeners();
  }

  void continueAfterWin() {
    _board = _board.copyWith(state: GameState.playing);
    notifyListeners();
  }

  Future<void> saveScoreToLeaderboard() async {
    if (!isRankingEligible) return;

    final username = await UserService.getUsername();
    if (username != null && _board.score > 0) {
      await LeaderboardService.saveScore(username, _board.score);
    }
  }

  // Magic: Start double tile selection
  void startDoubleTileSelection() {
    if (!canDouble) return;
    _selectionMode = MagicSelectionMode.doubleTile;
    notifyListeners();
  }

  // Magic: Start swap tiles selection
  void startSwapTilesSelection() {
    if (!canSwap) return;
    _selectionMode = MagicSelectionMode.swapFirst;
    _firstSwapTile = null;
    notifyListeners();
  }

  // Magic: Start remove tile selection
  void startRemoveTileSelection() {
    if (!canRemove) return;
    _selectionMode = MagicSelectionMode.removeTile;
    notifyListeners();
  }

  // Magic: Cancel any magic selection
  void cancelMagicSelection() {
    _selectionMode = MagicSelectionMode.none;
    _firstSwapTile = null;
    notifyListeners();
  }

  // Handle tile selection for magic abilities
  void onTileSelected(Tile tile) {
    switch (_selectionMode) {
      case MagicSelectionMode.none:
        return;

      case MagicSelectionMode.doubleTile:
        if (!canDouble) return;
        _board = _board.doubleTile(tile);
        _board = _board.copyWith(score: _board.score - MagicCosts.doubleTile);
        _selectionMode = MagicSelectionMode.none;
        notifyListeners();

      case MagicSelectionMode.swapFirst:
        _firstSwapTile = tile;
        _selectionMode = MagicSelectionMode.swapSecond;
        notifyListeners();

      case MagicSelectionMode.swapSecond:
        if (_firstSwapTile != null && _firstSwapTile!.id != tile.id) {
          if (!canSwap) return;
          _board = _board.swapTiles(_firstSwapTile!, tile);
          _board = _board.copyWith(score: _board.score - MagicCosts.swapTiles);
          _selectionMode = MagicSelectionMode.none;
          _firstSwapTile = null;
          notifyListeners();
        }

      case MagicSelectionMode.removeTile:
        if (!canRemove) return;
        _board = _board.removeTile(tile);
        _board = _board.copyWith(score: _board.score - MagicCosts.removeTile);
        _selectionMode = MagicSelectionMode.none;
        notifyListeners();
    }
  }

  // Magic: Regenerate last tile
  void regenerateLastTile() {
    if (!canRegenerate) return;
    _board = _board.regenerateLastTile();
    _board = _board.copyWith(score: _board.score - MagicCosts.regenerate);
    notifyListeners();
  }
}
