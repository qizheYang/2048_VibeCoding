import 'package:flutter/material.dart';

import 'package:magicful_2048/models/tile.dart';
import 'package:magicful_2048/utils/constants.dart';

class AnimatedTile extends StatefulWidget {
  final Tile tile;
  final double tileSize;
  final bool isSelected;
  final bool isSelectable;
  final VoidCallback? onTap;

  const AnimatedTile({
    super.key,
    required this.tile,
    required this.tileSize,
    this.isSelected = false,
    this.isSelectable = false,
    this.onTap,
  });

  @override
  State<AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<AnimatedTile> with TickerProviderStateMixin {
  late AnimationController _moveController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    if (widget.tile.isNew || widget.tile.isMerged) {
      _scaleController.forward();
    }

    if (widget.tile.hasMoved) {
      _moveController.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.tile.isNew || widget.tile.isMerged) {
      _scaleController.reset();
      _scaleController.forward();
    }

    if (widget.tile.hasMoved && oldWidget.tile.id != widget.tile.id) {
      _moveController.reset();
      _moveController.forward();
    }
  }

  @override
  void dispose() {
    _moveController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_moveController, _scaleController]),
      builder: (context, child) {
        double scale = 1.0;
        if (widget.tile.isNew || widget.tile.isMerged) {
          scale = _scaleAnimation.value;
        }

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: widget.isSelectable ? widget.onTap : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                color: GameColors.getTileColor(widget.tile.value),
                borderRadius: BorderRadius.circular(GameSizes.tileBorderRadius),
                border: widget.isSelected
                    ? Border.all(color: Colors.blue, width: 3)
                    : widget.isSelectable
                        ? Border.all(color: Colors.blue.withValues(alpha: 0.5), width: 2)
                        : null,
                boxShadow: widget.tile.isDoubled
                    ? [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.tile.value.toString(),
                      style: TextStyle(
                        color: GameColors.getTextColor(widget.tile.value),
                        fontSize: _getFontSize(widget.tile.value),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _getFontSize(int value) {
    if (value < 100) return 32;
    if (value < 1000) return 26;
    return 20;
  }
}
