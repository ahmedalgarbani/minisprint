import 'dart:convert';

import '../../domain/entities/board_config.dart';
import '../../domain/entities/task.dart';

class BoardConfigModel {
  const BoardConfigModel._();

  static BoardConfig fromJson(String value) =>
      fromMap(jsonDecode(value) as Map<String, dynamic>);

  static String toJson(BoardConfig config) => jsonEncode(toMap(config));

  static BoardConfig fromMap(Map<String, dynamic> map) {
    final columns = ((map['columns'] as List<dynamic>?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_columnFromMap)
        .toList();
    return BoardConfig(
      columns: columns.isEmpty ? BoardConfig.advancedColumns : columns,
      filter: _filterFromMap(
        (map['filter'] as Map<String, dynamic>?) ?? const {},
      ),
      sortField: _enumByName(
        BoardSortField.values,
        map['sortField'],
        BoardSortField.priority,
      ),
      sortDirection: _enumByName(
        SortDirection.values,
        map['sortDirection'],
        SortDirection.descending,
      ),
      grouping: _enumByName(
        BoardGrouping.values,
        map['grouping'],
        BoardGrouping.none,
      ),
    );
  }

  static Map<String, dynamic> toMap(BoardConfig config) => {
    'columns': config.columns.map(_columnToMap).toList(),
    'filter': _filterToMap(config.filter),
    'sortField': config.sortField.name,
    'sortDirection': config.sortDirection.name,
    'grouping': config.grouping.name,
  };

  static T _enumByName<T extends Enum>(
    List<T> values,
    Object? name,
    T fallback,
  ) => values.asNameMap()[name] ?? fallback;

  static BoardColumnConfig _columnFromMap(Map<String, dynamic> map) {
    return BoardColumnConfig(
      id: map['id'] as String,
      title: map['title'] as String? ?? map['id'] as String,
      wipLimit: map['wipLimit'] as int?,
      enabled: map['enabled'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> _columnToMap(BoardColumnConfig column) => {
    'id': column.id,
    'title': column.title,
    'wipLimit': column.wipLimit,
    'enabled': column.enabled,
  };

  static BoardFilter _filterFromMap(Map<String, dynamic> map) {
    return BoardFilter(
      priorities: ((map['priorities'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toSet(),
      types: ((map['types'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .map(WorkItemType.fromValue)
          .toSet(),
      assignee: map['assignee'] as String? ?? '',
      tag: map['tag'] as String? ?? '',
    );
  }

  static Map<String, dynamic> _filterToMap(BoardFilter filter) => {
    'priorities': filter.priorities.toList(),
    'types': filter.types.map((t) => t.name).toList(),
    'assignee': filter.assignee,
    'tag': filter.tag,
  };
}
