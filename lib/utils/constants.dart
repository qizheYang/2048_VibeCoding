import 'package:flutter/material.dart';

class GameColors {
  static const Color background = Color(0xFFFAF8EF);
  static const Color gridBackground = Color(0xFFBBADA0);
  static const Color emptyTile = Color(0xFFCDC1B4);
  static const Color lightText = Color(0xFF776E65);
  static const Color whiteText = Color(0xFFF9F6F2);

  static const Map<int, Color> tileColors = {
    2: Color(0xFFEEE4DA),
    4: Color(0xFFEDE0C8),
    8: Color(0xFFF2B179),
    16: Color(0xFFF59563),
    32: Color(0xFFF67C5F),
    64: Color(0xFFF65E3B),
    128: Color(0xFFEDCF72),
    256: Color(0xFFEDCC61),
    512: Color(0xFFEDC850),
    1024: Color(0xFFEDC53F),
    2048: Color(0xFFEDC22E),
  };

  static Color getTileColor(int value) {
    return tileColors[value] ?? const Color(0xFF3C3A32);
  }

  static Color getTextColor(int value) {
    return value <= 4 ? lightText : whiteText;
  }
}

class GameSizes {
  static const int defaultGridSize = 4;
  static const int rankingGridSize = 4;
  static const List<int> availableGridSizes = [3, 4, 5, 6];
  static const double gridPadding = 12.0;
  static const double tileSpacing = 8.0;
  static const double tileBorderRadius = 6.0;
}

class MagicCosts {
  // Costs are based on risk/reward:
  // - Double: Very powerful, can create high-value tiles quickly = 100 points
  // - Swap: Tactical repositioning, moderate impact = 50 points
  // - Regenerate: Minor convenience, luck-based = 25 points
  // - Remove: Extremely powerful, removes problem tiles = 150 points
  static const int doubleTile = 100;
  static const int swapTiles = 50;
  static const int regenerate = 25;
  static const int removeTile = 150;
}
