import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:magicful_2048/models/tile.dart';
import 'package:magicful_2048/providers/game_provider.dart';
import 'package:magicful_2048/utils/constants.dart';
import 'package:magicful_2048/widgets/animated_tile.dart';

class AnimatedGameGrid extends StatelessWidget {
  const AnimatedGameGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final gridSize = gameProvider.board.gridSize;

        return AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final containerSize = constraints.maxWidth;
              final tileSize = (containerSize - GameSizes.gridPadding * 2 - GameSizes.tileSpacing * (gridSize - 1)) / gridSize;

              return Container(
                padding: const EdgeInsets.all(GameSizes.gridPadding),
                decoration: BoxDecoration(
                  color: GameColors.gridBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    // Empty tile backgrounds
                    ...List.generate(gridSize * gridSize, (index) {
                      final row = index ~/ gridSize;
                      final col = index % gridSize;
                      return Positioned(
                        left: col * (tileSize + GameSizes.tileSpacing),
                        top: row * (tileSize + GameSizes.tileSpacing),
                        width: tileSize,
                        height: tileSize,
                        child: Container(
                          decoration: BoxDecoration(
                            color: GameColors.emptyTile,
                            borderRadius: BorderRadius.circular(GameSizes.tileBorderRadius),
                          ),
                        ),
                      );
                    }),
                    // Animated tiles
                    ...gameProvider.board.tiles.map((tile) {
                      final isSelectable = _isTileSelectable(gameProvider, tile);
                      final isSelected = _isTileSelected(gameProvider, tile);

                      return AnimatedPositioned(
                        key: ValueKey(tile.id),
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        left: tile.col * (tileSize + GameSizes.tileSpacing),
                        top: tile.row * (tileSize + GameSizes.tileSpacing),
                        width: tileSize,
                        height: tileSize,
                        child: AnimatedTile(
                          tile: tile,
                          tileSize: tileSize,
                          isSelectable: isSelectable,
                          isSelected: isSelected,
                          onTap: isSelectable ? () => gameProvider.onTileSelected(tile) : null,
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  bool _isTileSelectable(GameProvider provider, Tile tile) {
    return provider.selectionMode == MagicSelectionMode.doubleTile ||
        provider.selectionMode == MagicSelectionMode.swapFirst ||
        provider.selectionMode == MagicSelectionMode.swapSecond ||
        provider.selectionMode == MagicSelectionMode.removeTile;
  }

  bool _isTileSelected(GameProvider provider, Tile tile) {
    return provider.selectionMode == MagicSelectionMode.swapSecond &&
        provider.firstSwapTile?.id == tile.id;
  }
}
