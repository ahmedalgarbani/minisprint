import 'package:equatable/equatable.dart';

import 'board_config.dart';
import 'task.dart';

/// One swimlane. With [BoardGrouping.none] the board has a single lane.
class BoardLane extends Equatable {
  /// Raw group value: a priority, assignee or [WorkItemType.name].
  /// Empty for the single lane and for unassigned tasks.
  final String value;

  /// Tasks per column id.
  final Map<String, List<Task>> cells;

  const BoardLane({required this.value, required this.cells});

  int get count => cells.values.fold(0, (sum, list) => sum + list.length);

  @override
  List<Object?> get props => [value, cells];
}

/// Everything the board UI needs to render, already filtered and sorted.
class BoardView extends Equatable {
  final List<BoardColumnConfig> columns;
  final BoardGrouping grouping;
  final List<BoardLane> lanes;

  /// Tasks per column before filtering (used for WIP limits).
  final Map<String, int> columnCounts;
  final int totalCount;
  final int visibleCount;

  const BoardView({
    required this.columns,
    required this.grouping,
    required this.lanes,
    required this.columnCounts,
    required this.totalCount,
    required this.visibleCount,
  });

  bool get isFiltered => visibleCount != totalCount;

  int countFor(String columnId) => columnCounts[columnId] ?? 0;

  bool isOverWipLimit(BoardColumnConfig column) {
    final limit = column.wipLimit;
    return limit != null && countFor(column.id) > limit;
  }

  @override
  List<Object?> get props => [
    columns,
    grouping,
    lanes,
    columnCounts,
    totalCount,
    visibleCount,
  ];
}
