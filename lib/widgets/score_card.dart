import 'package:flutter/material.dart';

import 'package:magicful_2048/utils/constants.dart';

class ScoreCard extends StatelessWidget {
  final String label;
  final int score;

  const ScoreCard({
    super.key,
    required this.label,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: GameColors.gridBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: GameColors.emptyTile,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            score.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
