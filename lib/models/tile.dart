import 'package:flutter/foundation.dart';

@immutable
class Tile {
  final int id;
  final int value;
  final int row;
  final int col;
  final int? previousRow;
  final int? previousCol;
  final bool isNew;
  final bool isMerged;
  final bool isDoubled;

  const Tile({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
    this.previousRow,
    this.previousCol,
    this.isNew = false,
    this.isMerged = false,
    this.isDoubled = false,
  });

  Tile copyWith({
    int? id,
    int? value,
    int? row,
    int? col,
    int? previousRow,
    int? previousCol,
    bool? isNew,
    bool? isMerged,
    bool? isDoubled,
    bool clearPrevious = false,
  }) {
    return Tile(
      id: id ?? this.id,
      value: value ?? this.value,
      row: row ?? this.row,
      col: col ?? this.col,
      previousRow: clearPrevious ? null : (previousRow ?? this.previousRow),
      previousCol: clearPrevious ? null : (previousCol ?? this.previousCol),
      isNew: isNew ?? this.isNew,
      isMerged: isMerged ?? this.isMerged,
      isDoubled: isDoubled ?? this.isDoubled,
    );
  }

  bool get hasMoved => previousRow != null && previousCol != null && (previousRow != row || previousCol != col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tile && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Tile(id: $id, value: $value, row: $row, col: $col, doubled: $isDoubled)';
}
