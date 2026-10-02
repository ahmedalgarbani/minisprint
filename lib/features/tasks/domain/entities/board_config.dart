import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';
import 'task.dart';

enum BoardSortField { priority, title, assignee, storyPoints, created }

enum SortDirection { ascending, descending }

/// Swimlanes, as in Jira "Group by" / Azure DevOps board swimlanes.
enum BoardGrouping { none, priority, assignee, type }

class BoardColumnConfig extends Equatable {
  /// The task status this column represents.
  final String id;
  final String title;
  final int? wipLimit;
  final bool enabled;

  const BoardColumnConfig({
    required this.id,
    required this.title,
    this.wipLimit,
    this.enabled = true,
  });

  BoardColumnConfig copyWith({
    String? title,
    int? wipLimit,
    bool clearWipLimit = false,
    bool? enabled,
  }) {
    return BoardColumnConfig(
      id: id,
      title: title ?? this.title,
      wipLimit: clearWipLimit ? null : wipLimit ?? this.wipLimit,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List<Object?> get props => [id, title, wipLimit, enabled];
}

class BoardFilter extends Equatable {
  final Set<String> priorities;
  final Set<WorkItemType> types;
  final String assignee;
  final String tag;

  const BoardFilter({
    this.priorities = const {},
    this.types = const {},
    this.assignee = '',
    this.tag = '',
  });

  bool get isEmpty =>
      priorities.isEmpty && types.isEmpty && assignee.isEmpty && tag.isEmpty;

  int get activeCount =>
      (priorities.isEmpty ? 0 : 1) +
      (types.isEmpty ? 0 : 1) +
      (assignee.isEmpty ? 0 : 1) +
      (tag.isEmpty ? 0 : 1);

  BoardFilter copyWith({
    Set<String>? priorities,
    Set<WorkItemType>? types,
    String? assignee,
    String? tag,
  }) {
    return BoardFilter(
      priorities: priorities ?? this.priorities,
      types: types ?? this.types,
      assignee: assignee ?? this.assignee,
      tag: tag ?? this.tag,
    );
  }

  @override
  List<Object?> get props => [priorities, types, assignee, tag];
}

/// Per-project board settings used in advanced mode.
class BoardConfig extends Equatable {
  final List<BoardColumnConfig> columns;
  final BoardFilter filter;
  final BoardSortField sortField;
  final SortDirection sortDirection;
  final BoardGrouping grouping;

  const BoardConfig({
    this.columns = advancedColumns,
    this.filter = const BoardFilter(),
    this.sortField = BoardSortField.priority,
    this.sortDirection = SortDirection.descending,
    this.grouping = BoardGrouping.none,
  });

  static const simpleColumns = [
    BoardColumnConfig(id: TaskStatus.todo, title: TaskStatus.todo),
    BoardColumnConfig(id: TaskStatus.inProgress, title: TaskStatus.inProgress),
    BoardColumnConfig(id: TaskStatus.done, title: TaskStatus.done),
  ];

  static const advancedColumns = [
    BoardColumnConfig(id: TaskStatus.todo, title: TaskStatus.todo),
    BoardColumnConfig(
      id: TaskStatus.inProgress,
      title: TaskStatus.inProgress,
      wipLimit: 5,
    ),
    BoardColumnConfig(
      id: TaskStatus.review,
      title: TaskStatus.review,
      wipLimit: 3,
    ),
    BoardColumnConfig(id: TaskStatus.done, title: TaskStatus.done),
  ];

  BoardConfig copyWith({
    List<BoardColumnConfig>? columns,
    BoardFilter? filter,
    BoardSortField? sortField,
    SortDirection? sortDirection,
    BoardGrouping? grouping,
  }) {
    return BoardConfig(
      columns: columns ?? this.columns,
      filter: filter ?? this.filter,
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
      grouping: grouping ?? this.grouping,
    );
  }

  @override
  List<Object?> get props => [
    columns,
    filter,
    sortField,
    sortDirection,
    grouping,
  ];
}
