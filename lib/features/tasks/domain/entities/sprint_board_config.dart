import 'package:equatable/equatable.dart';

enum BoardMode { simple, professional }

enum BoardSortField { title, priority, assignee }

enum SortDirection { ascending, descending }

class BoardColumnConfig extends Equatable {
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
    String? id,
    String? title,
    int? wipLimit,
    bool clearWipLimit = false,
    bool? enabled,
  }) {
    return BoardColumnConfig(
      id: id ?? this.id,
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
  final String assignee;
  final String tag;

  const BoardFilter({
    this.priorities = const {},
    this.assignee = '',
    this.tag = '',
  });

  BoardFilter copyWith({
    Set<String>? priorities,
    String? assignee,
    String? tag,
  }) {
    return BoardFilter(
      priorities: priorities ?? this.priorities,
      assignee: assignee ?? this.assignee,
      tag: tag ?? this.tag,
    );
  }

  @override
  List<Object?> get props => [priorities, assignee, tag];
}

class SprintBoardConfig extends Equatable {
  final BoardMode mode;
  final List<BoardColumnConfig> columns;
  final BoardFilter filter;
  final BoardSortField sortField;
  final SortDirection sortDirection;

  const SprintBoardConfig({
    required this.mode,
    required this.columns,
    this.filter = const BoardFilter(),
    this.sortField = BoardSortField.priority,
    this.sortDirection = SortDirection.descending,
  });

  factory SprintBoardConfig.defaults({BoardMode mode = BoardMode.simple}) {
    return SprintBoardConfig(
      mode: mode,
      columns: mode == BoardMode.simple
          ? simpleColumns
          : professionalColumns,
    );
  }

  static const simpleColumns = [
    BoardColumnConfig(id: 'To Do', title: 'To Do'),
    BoardColumnConfig(id: 'In Progress', title: 'In Progress'),
    BoardColumnConfig(id: 'Done', title: 'Done'),
  ];

  static const professionalColumns = [
    BoardColumnConfig(id: 'Backlog', title: 'Backlog'),
    BoardColumnConfig(id: 'To Do', title: 'To Do', wipLimit: 8),
    BoardColumnConfig(id: 'In Progress', title: 'In Progress', wipLimit: 4),
    BoardColumnConfig(id: 'Review', title: 'Review', wipLimit: 3),
    BoardColumnConfig(id: 'Done', title: 'Done'),
  ];

  SprintBoardConfig copyWith({
    BoardMode? mode,
    List<BoardColumnConfig>? columns,
    BoardFilter? filter,
    BoardSortField? sortField,
    SortDirection? sortDirection,
  }) {
    return SprintBoardConfig(
      mode: mode ?? this.mode,
      columns: columns ?? this.columns,
      filter: filter ?? this.filter,
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    columns,
    filter,
    sortField,
    sortDirection,
  ];
}
