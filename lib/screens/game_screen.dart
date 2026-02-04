import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:magicful_2048/models/game_board.dart';
import 'package:magicful_2048/providers/game_provider.dart';
import 'package:magicful_2048/screens/entry_screen.dart';
import 'package:magicful_2048/utils/constants.dart';
import 'package:magicful_2048/widgets/animated_game_grid.dart';
import 'package:magicful_2048/widgets/score_card.dart';
import 'package:magicful_2048/widgets/magic_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FocusNode _focusNode = FocusNode();
  bool _scoreSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: (event) => _handleKeyEvent(context, event),
          child: GestureDetector(
            onVerticalDragEnd: (details) => _handleVerticalSwipe(context, details),
            onHorizontalDragEnd: (details) => _handleHorizontalSwipe(context, details),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 12),
                  _buildMagicBar(context),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: const AnimatedGameGrid(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInstructions(context),
                  _buildGameOverlay(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '2048',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: GameColors.lightText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: gameProvider.isRankingEligible
                            ? Colors.amber.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${gameProvider.gridSize}x${gameProvider.gridSize}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: gameProvider.isRankingEligible
                              ? Colors.amber.shade700
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Magicful Edition',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.deepPurple.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    ScoreCard(label: 'SCORE', score: gameProvider.score),
                    const SizedBox(width: 6),
                    ScoreCard(label: 'BEST', score: gameProvider.bestScore),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _navigateToEntry(context),
                      style: TextButton.styleFrom(
                        foregroundColor: GameColors.lightText,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, size: 16),
                          SizedBox(width: 4),
                          Text('Menu'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: () {
                        _scoreSaved = false;
                        gameProvider.startNewGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GameColors.gridBackground,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('New', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMagicBar(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final isSelecting = gameProvider.selectionMode != MagicSelectionMode.none;

        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MagicButton(
                    icon: Icons.double_arrow,
                    label: 'Double',
                    cost: MagicCosts.doubleTile,
                    canAfford: gameProvider.canDouble,
                    isActive: gameProvider.selectionMode == MagicSelectionMode.doubleTile,
                    onPressed: () {
                      if (gameProvider.selectionMode == MagicSelectionMode.doubleTile) {
                        gameProvider.cancelMagicSelection();
                      } else {
                        gameProvider.startDoubleTileSelection();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  MagicButton(
                    icon: Icons.swap_horiz,
                    label: 'Swap',
                    cost: MagicCosts.swapTiles,
                    canAfford: gameProvider.canSwap,
                    isActive: gameProvider.selectionMode == MagicSelectionMode.swapFirst ||
                        gameProvider.selectionMode == MagicSelectionMode.swapSecond,
                    onPressed: () {
                      if (gameProvider.selectionMode == MagicSelectionMode.swapFirst ||
                          gameProvider.selectionMode == MagicSelectionMode.swapSecond) {
                        gameProvider.cancelMagicSelection();
                      } else {
                        gameProvider.startSwapTilesSelection();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  MagicButton(
                    icon: Icons.refresh,
                    label: 'Regen',
                    cost: MagicCosts.regenerate,
                    canAfford: gameProvider.canRegenerate,
                    onPressed: gameProvider.canRegenerate ? () => gameProvider.regenerateLastTile() : null,
                  ),
                  const SizedBox(width: 8),
                  MagicButton(
                    icon: Icons.delete_outline,
                    label: 'Remove',
                    cost: MagicCosts.removeTile,
                    canAfford: gameProvider.canRemove,
                    isActive: gameProvider.selectionMode == MagicSelectionMode.removeTile,
                    onPressed: () {
                      if (gameProvider.selectionMode == MagicSelectionMode.removeTile) {
                        gameProvider.cancelMagicSelection();
                      } else {
                        gameProvider.startRemoveTileSelection();
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  // Undo button - free!
                  _buildUndoButton(gameProvider),
                ],
              ),
            ),
            if (isSelecting) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.touch_app, color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _getSelectionHint(gameProvider.selectionMode),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => gameProvider.cancelMagicSelection(),
                      child: const Icon(Icons.close, color: Colors.blue, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildUndoButton(GameProvider gameProvider) {
    final canUndo = gameProvider.canUndo;
    return Opacity(
      opacity: canUndo ? 1.0 : 0.5,
      child: InkWell(
        onTap: canUndo ? () => gameProvider.undo() : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.undo, color: Colors.white, size: 22),
              const SizedBox(height: 2),
              const Text(
                'Undo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'FREE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSelectionHint(MagicSelectionMode mode) {
    switch (mode) {
      case MagicSelectionMode.none:
        return '';
      case MagicSelectionMode.doubleTile:
        return 'Tap a tile to double its value';
      case MagicSelectionMode.swapFirst:
        return 'Tap the first tile to swap';
      case MagicSelectionMode.swapSecond:
        return 'Tap the second tile to swap';
      case MagicSelectionMode.removeTile:
        return 'Tap a tile to remove it';
    }
  }

  Widget _buildInstructions(BuildContext context) {
    return Center(
      child: Text(
        'Use arrow keys or swipe to move tiles',
        style: TextStyle(
          color: GameColors.lightText.withValues(alpha: 0.6),
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildGameOverlay(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (gameProvider.state == GameState.playing) {
          return const SizedBox.shrink();
        }

        // Save score when game ends
        if (!_scoreSaved && gameProvider.state == GameState.lost) {
          _scoreSaved = true;
          gameProvider.saveScoreToLeaderboard();
        }

        final isWon = gameProvider.state == GameState.won;
        return Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isWon
                ? Colors.amber.withValues(alpha: 0.95)
                : Colors.grey.shade700.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isWon ? 'You Win!' : 'Game Over',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: ${gameProvider.score}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              if (!gameProvider.isRankingEligible) ...[
                const SizedBox(height: 4),
                Text(
                  '(Not ranked - ${gameProvider.gridSize}x${gameProvider.gridSize} mode)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _scoreSaved = false;
                      gameProvider.startNewGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: isWon ? Colors.amber.shade700 : Colors.grey.shade700,
                    ),
                    child: const Text('New Game'),
                  ),
                  if (isWon) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => gameProvider.continueAfterWin(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Continue'),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _navigateToEntry(context),
                child: Text(
                  'Back to Menu',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToEntry(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const EntryScreen()),
    );
  }

  void _handleKeyEvent(BuildContext context, KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final gameProvider = context.read<GameProvider>();

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      gameProvider.cancelMagicSelection();
      return;
    }

    if (gameProvider.selectionMode != MagicSelectionMode.none) return;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        gameProvider.move(MoveDirection.up);
      case LogicalKeyboardKey.arrowDown:
        gameProvider.move(MoveDirection.down);
      case LogicalKeyboardKey.arrowLeft:
        gameProvider.move(MoveDirection.left);
      case LogicalKeyboardKey.arrowRight:
        gameProvider.move(MoveDirection.right);
    }
  }

  void _handleVerticalSwipe(BuildContext context, DragEndDetails details) {
    final gameProvider = context.read<GameProvider>();
    if (gameProvider.selectionMode != MagicSelectionMode.none) return;

    if (details.velocity.pixelsPerSecond.dy < -100) {
      gameProvider.move(MoveDirection.up);
    } else if (details.velocity.pixelsPerSecond.dy > 100) {
      gameProvider.move(MoveDirection.down);
    }
  }

  void _handleHorizontalSwipe(BuildContext context, DragEndDetails details) {
    final gameProvider = context.read<GameProvider>();
    if (gameProvider.selectionMode != MagicSelectionMode.none) return;

    if (details.velocity.pixelsPerSecond.dx < -100) {
      gameProvider.move(MoveDirection.left);
    } else if (details.velocity.pixelsPerSecond.dx > 100) {
      gameProvider.move(MoveDirection.right);
    }
  }
}
