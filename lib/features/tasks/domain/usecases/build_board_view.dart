import '../../../../core/constants/app_constants.dart';
import '../../../../core/preferences/work_mode.dart';
import '../entities/board_config.dart';
import '../entities/board_view.dart';
import '../entities/task.dart';

/// Pure function: turns a sprint's tasks + board settings into a [BoardView].
class BuildBoardView {
  const BuildBoardView();

  BoardView call({
    required List<Task> tasks,
    required BoardConfig config,
    required WorkMode mode,
    String query = '',
    String projectKey = '',
  }) {
    final advanced = mode.isAdvanced;
    final columns = advanced
        ? config.columns.where((c) => c.enabled).toList()
        : BoardConfig.simpleColumns;
    final grouping = advanced ? config.grouping : BoardGrouping.none;

    final visible = tasks
        .where((t) => _matchesQuery(t, query, projectKey))
        .where((t) => !advanced || _matchesFilter(t, config.filter))
        .toList();
    _sort(
      visible,
      advanced ? config.sortField : BoardSortField.priority,
      advanced ? config.sortDirection : SortDirection.descending,
    );

    // WIP counts use every task in the column, not just the filtered ones,
    // so a search or filter never hides a limit violation.
    final counts = {for (final c in columns) c.id: 0};
    if (columns.isNotEmpty) {
      for (final task in tasks) {
        final columnId = resolveColumnId(task.status, columns);
        counts[columnId] = counts[columnId]! + 1;
      }
    }
    final lanesByValue = <String, Map<String, List<Task>>>{};
    for (final task in visible) {
      if (columns.isEmpty) break;
      final columnId = resolveColumnId(task.status, columns);
      final lane = lanesByValue.putIfAbsent(
        _laneValue(task, grouping),
        () => {for (final c in columns) c.id: <Task>[]},
      );
      lane[columnId]!.add(task);
    }

    final laneValues = lanesByValue.keys.toList()
      ..sort((a, b) => _compareLanes(a, b, grouping));
    final lanes = [
      for (final value in laneValues)
        BoardLane(value: value, cells: lanesByValue[value]!),
    ];
    if (lanes.isEmpty && grouping == BoardGrouping.none) {
      lanes.add(
        BoardLane(value: '', cells: {for (final c in columns) c.id: []}),
      );
    }

    return BoardView(
      columns: columns,
      grouping: grouping,
      lanes: lanes,
      columnCounts: counts,
      totalCount: tasks.length,
      visibleCount: visible.length,
    );
  }

  bool _matchesQuery(Task task, String query, String projectKey) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return task.title.toLowerCase().contains(q) ||
        task.description.toLowerCase().contains(q) ||
        task.assignee.toLowerCase().contains(q) ||
        task.tags.any((tag) => tag.toLowerCase().contains(q)) ||
        task.keyFor(projectKey).toLowerCase().contains(q);
  }

  bool _matchesFilter(Task task, BoardFilter filter) {
    if (filter.priorities.isNotEmpty &&
        !filter.priorities.contains(task.priority)) {
      return false;
    }
    if (filter.types.isNotEmpty && !filter.types.contains(task.type)) {
      return false;
    }
    final assignee = filter.assignee.toLowerCase();
    if (assignee.isNotEmpty &&
        !task.assignee.toLowerCase().contains(assignee)) {
      return false;
    }
    final tag = filter.tag.toLowerCase();
    if (tag.isNotEmpty &&
        !task.tags.any((t) => t.toLowerCase().contains(tag))) {
      return false;
    }
    return true;
  }

  void _sort(List<Task> tasks, BoardSortField field, SortDirection direction) {
    int compare(Task a, Task b) => switch (field) {
      BoardSortField.priority => priorityWeight(
        a.priority,
      ).compareTo(priorityWeight(b.priority)),
      BoardSortField.title => a.title.toLowerCase().compareTo(
        b.title.toLowerCase(),
      ),
      BoardSortField.assignee => a.assignee.toLowerCase().compareTo(
        b.assignee.toLowerCase(),
      ),
      BoardSortField.storyPoints => (a.storyPoints ?? 0).compareTo(
        b.storyPoints ?? 0,
      ),
      BoardSortField.created => (a.id ?? 0).compareTo(b.id ?? 0),
    };
    tasks.sort((a, b) {
      final value = compare(a, b);
      final directed = direction == SortDirection.ascending ? value : -value;
      // Stable tie-break so equal items never jump around.
      return directed != 0 ? directed : (a.id ?? 0).compareTo(b.id ?? 0);
    });
  }

  String _laneValue(Task task, BoardGrouping grouping) => switch (grouping) {
    BoardGrouping.none => '',
    BoardGrouping.priority => task.priority,
    BoardGrouping.assignee => task.assignee.trim(),
    BoardGrouping.type => task.type.name,
  };

  int _compareLanes(String a, String b, BoardGrouping grouping) {
    switch (grouping) {
      case BoardGrouping.none:
        return 0;
      case BoardGrouping.priority:
        return priorityWeight(b).compareTo(priorityWeight(a));
      case BoardGrouping.type:
        return WorkItemType.fromValue(
          a,
        ).index.compareTo(WorkItemType.fromValue(b).index);
      case BoardGrouping.assignee:
        // Unassigned last.
        if (a.isEmpty != b.isEmpty) return a.isEmpty ? 1 : -1;
        return a.toLowerCase().compareTo(b.toLowerCase());
    }
  }
}

/// Which column shows a task with [status].
///
/// Exact match first; otherwise the closest standard column, so no task is
/// ever hidden just because the board has fewer columns than statuses
/// (e.g. a `Review` task on the 3-column simple board).
String resolveColumnId(String status, List<BoardColumnConfig> columns) {
  String? find(String id) {
    for (final column in columns) {
      if (column.id.toLowerCase() == id.toLowerCase()) return column.id;
    }
    return null;
  }

  final exact = find(status);
  if (exact != null) return exact;
  final fallback = switch (status) {
    TaskStatus.backlog => find(TaskStatus.todo),
    TaskStatus.review => find(TaskStatus.inProgress),
    _ => null,
  };
  if (fallback != null) return fallback;
  if (status == TaskStatus.done) return columns.last.id;
  return columns.first.id;
}
