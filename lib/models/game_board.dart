import 'dart:math';

import 'package:magicful_2048/models/tile.dart';
import 'package:magicful_2048/utils/constants.dart';

enum MoveDirection { up, down, left, right }

enum GameState { playing, won, lost }

enum MagicType { doubleTile, swapTiles, regenerate, removeTile }

class GameBoard {
  final List<Tile> tiles;
  final int score;
  final int gridSize;
  final GameState state;
  final Tile? lastAddedTile;
  final Random _random = Random();
  int _nextId;

  GameBoard({
    List<Tile>? tiles,
    this.score = 0,
    this.gridSize = GameSizes.defaultGridSize,
    this.state = GameState.playing,
    this.lastAddedTile,
    int nextId = 0,
  })  : tiles = tiles ?? [],
        _nextId = nextId;

  int get nextId => _nextId;

  GameBoard copyWith({
    List<Tile>? tiles,
    int? score,
    int? gridSize,
    GameState? state,
    Tile? lastAddedTile,
    int? nextId,
    bool clearLastAdded = false,
  }) {
    return GameBoard(
      tiles: tiles ?? List.from(this.tiles),
      score: score ?? this.score,
      gridSize: gridSize ?? this.gridSize,
      state: state ?? this.state,
      lastAddedTile: clearLastAdded ? null : (lastAddedTile ?? this.lastAddedTile),
      nextId: nextId ?? _nextId,
    );
  }

  List<List<int>> get grid {
    final result = List.generate(
      gridSize,
      (_) => List.filled(gridSize, 0),
    );
    for (final tile in tiles) {
      result[tile.row][tile.col] = tile.value;
    }
    return result;
  }

  Tile? getTileAt(int row, int col) {
    for (final tile in tiles) {
      if (tile.row == row && tile.col == col) return tile;
    }
    return null;
  }

  GameBoard initialize({int? size}) {
    final newSize = size ?? gridSize;
    return GameBoard(gridSize: newSize, nextId: 0)._addRandomTile()._addRandomTile();
  }

  GameBoard clearAnimationStates() {
    final clearedTiles = tiles.map((t) => t.copyWith(
      isNew: false,
      isMerged: false,
      clearPrevious: true,
    )).toList();
    return copyWith(tiles: clearedTiles, clearLastAdded: true);
  }

  GameBoard _addRandomTile() {
    final emptyCells = <(int, int)>[];
    final grid = this.grid;
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col] == 0) {
          emptyCells.add((row, col));
        }
      }
    }

    if (emptyCells.isEmpty) return this;

    final (row, col) = emptyCells[_random.nextInt(emptyCells.length)];
    final value = _random.nextDouble() < 0.9 ? 2 : 4;
    final newTile = Tile(id: _nextId, value: value, row: row, col: col, isNew: true);

    return copyWith(
      tiles: [...tiles, newTile],
      lastAddedTile: newTile,
      nextId: _nextId + 1,
    );
  }

  GameBoard move(MoveDirection direction) {
    if (state != GameState.playing) return this;

    final clearedBoard = clearAnimationStates();
    final result = clearedBoard._performMove(direction);
    if (!result.moved) return this;

    final newBoard = result.board._addRandomTile();
    final newState = _checkGameState(newBoard);

    return newBoard.copyWith(state: newState);
  }

  ({GameBoard board, bool moved}) _performMove(MoveDirection direction) {
    var moved = false;
    var newScore = score;
    final newTiles = <Tile>[];
    final processed = <int>{};

    List<(int, int)> getLineCoordinates(int lineIndex) {
      switch (direction) {
        case MoveDirection.left:
          return [for (int c = 0; c < gridSize; c++) (lineIndex, c)];
        case MoveDirection.right:
          return [for (int c = gridSize - 1; c >= 0; c--) (lineIndex, c)];
        case MoveDirection.up:
          return [for (int r = 0; r < gridSize; r++) (r, lineIndex)];
        case MoveDirection.down:
          return [for (int r = gridSize - 1; r >= 0; r--) (r, lineIndex)];
      }
    }

    (int, int) getTargetPosition(int lineIndex, int positionInLine) {
      switch (direction) {
        case MoveDirection.left:
          return (lineIndex, positionInLine);
        case MoveDirection.right:
          return (lineIndex, gridSize - 1 - positionInLine);
        case MoveDirection.up:
          return (positionInLine, lineIndex);
        case MoveDirection.down:
          return (gridSize - 1 - positionInLine, lineIndex);
      }
    }

    for (int lineIndex = 0; lineIndex < gridSize; lineIndex++) {
      final coords = getLineCoordinates(lineIndex);
      final lineTiles = <Tile>[];

      for (final (r, c) in coords) {
        final tile = getTileAt(r, c);
        if (tile != null && !processed.contains(tile.id)) {
          lineTiles.add(tile);
        }
      }

      int targetPos = 0;
      for (int i = 0; i < lineTiles.length; i++) {
        final tile = lineTiles[i];
        processed.add(tile.id);

        if (i + 1 < lineTiles.length &&
            lineTiles[i].value == lineTiles[i + 1].value &&
            !lineTiles[i].isDoubled && !lineTiles[i + 1].isDoubled) {
          final nextTile = lineTiles[i + 1];
          processed.add(nextTile.id);

          final (targetRow, targetCol) = getTargetPosition(lineIndex, targetPos);
          final mergedValue = tile.value * 2;

          int scoreToAdd = mergedValue;
          if (tile.isDoubled || nextTile.isDoubled) {
            scoreToAdd = mergedValue;
          }
          newScore += scoreToAdd;

          final mergedTile = Tile(
            id: _nextId,
            value: mergedValue,
            row: targetRow,
            col: targetCol,
            previousRow: tile.row,
            previousCol: tile.col,
            isMerged: true,
          );
          newTiles.add(mergedTile);
          _nextId++;

          if (tile.row != targetRow || tile.col != targetCol ||
              nextTile.row != targetRow || nextTile.col != targetCol) {
            moved = true;
          }

          targetPos++;
          i++;
        } else {
          final (targetRow, targetCol) = getTargetPosition(lineIndex, targetPos);

          if (tile.row != targetRow || tile.col != targetCol) {
            moved = true;
          }

          final movedTile = tile.copyWith(
            row: targetRow,
            col: targetCol,
            previousRow: tile.row,
            previousCol: tile.col,
            isDoubled: tile.isDoubled,
          );
          newTiles.add(movedTile);
          targetPos++;
        }
      }
    }

    return (
      board: copyWith(tiles: newTiles, score: newScore, nextId: _nextId),
      moved: moved,
    );
  }

  GameState _checkGameState(GameBoard board) {
    final grid = board.grid;

    for (int row = 0; row < board.gridSize; row++) {
      for (int col = 0; col < board.gridSize; col++) {
        if (grid[row][col] == 2048) return GameState.won;
        if (grid[row][col] == 0) return GameState.playing;
      }
    }

    for (int row = 0; row < board.gridSize; row++) {
      for (int col = 0; col < board.gridSize - 1; col++) {
        if (grid[row][col] == grid[row][col + 1]) return GameState.playing;
      }
    }

    for (int col = 0; col < board.gridSize; col++) {
      for (int row = 0; row < board.gridSize - 1; row++) {
        if (grid[row][col] == grid[row + 1][col]) return GameState.playing;
      }
    }

    return GameState.lost;
  }

  // Magic: Double a tile
  GameBoard doubleTile(Tile tile) {
    final tileIndex = tiles.indexWhere((t) => t.id == tile.id);
    if (tileIndex == -1) return this;

    final doubledTile = tile.copyWith(
      value: tile.value * 2,
      isDoubled: true,
    );

    final newTiles = List<Tile>.from(tiles);
    newTiles[tileIndex] = doubledTile;

    return copyWith(tiles: newTiles);
  }

  // Magic: Swap two tiles
  GameBoard swapTiles(Tile tile1, Tile tile2) {
    final index1 = tiles.indexWhere((t) => t.id == tile1.id);
    final index2 = tiles.indexWhere((t) => t.id == tile2.id);
    if (index1 == -1 || index2 == -1) return this;

    final newTiles = List<Tile>.from(tiles);
    newTiles[index1] = tile1.copyWith(
      row: tile2.row,
      col: tile2.col,
      previousRow: tile1.row,
      previousCol: tile1.col,
    );
    newTiles[index2] = tile2.copyWith(
      row: tile1.row,
      col: tile1.col,
      previousRow: tile2.row,
      previousCol: tile2.col,
    );

    return copyWith(tiles: newTiles);
  }

  // Magic: Regenerate new tile
  GameBoard regenerateLastTile() {
    if (lastAddedTile == null) return this;

    final newTiles = tiles.where((t) => t.id != lastAddedTile!.id).toList();
    final tempBoard = copyWith(tiles: newTiles, clearLastAdded: true);
    return tempBoard._addRandomTile();
  }

  // Magic: Remove a tile
  GameBoard removeTile(Tile tile) {
    final newTiles = tiles.where((t) => t.id != tile.id).toList();
    return copyWith(tiles: newTiles);
  }
}
