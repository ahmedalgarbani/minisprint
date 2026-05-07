import 'dart:convert';

import '../../domain/entities/sprint_board_config.dart';

class SprintBoardConfigModel {
  static SprintBoardConfig fromJson(String value) {
    final map = jsonDecode(value) as Map<String, dynamic>;
    return fromMap(map);
  }

  static SprintBoardConfig fromMap(Map<String, dynamic> map) {
    final mode = BoardMode.values.byName(
      map['mode'] as String? ?? BoardMode.simple.name,
    );
    return SprintBoardConfig(
      mode: mode,
      columns: ((map['columns'] as List<dynamic>?) ?? const [])
          .map((item) => _columnFromMap(item as Map<String, dynamic>))
          .toList(),
      filter: _filterFromMap(
        (map['filter'] as Map<String, dynamic>?) ?? const {},
      ),
      sortField: BoardSortField.values.byName(
        map['sortField'] as String? ?? BoardSortField.priority.name,
      ),
      sortDirection: SortDirection.values.byName(
        map['sortDirection'] as String? ?? SortDirection.descending.name,
      ),
    );
  }

  static String toJson(SprintBoardConfig config) {
    return jsonEncode(toMap(config));
  }

  static Map<String, dynamic> toMap(SprintBoardConfig config) {
    return {
      'mode': config.mode.name,
      'columns': config.columns.map(_columnToMap).toList(),
      'filter': _filterToMap(config.filter),
      'sortField': config.sortField.name,
      'sortDirection': config.sortDirection.name,
    };
  }

  static BoardColumnConfig _columnFromMap(Map<String, dynamic> map) {
    return BoardColumnConfig(
      id: map['id'] as String,
      title: map['title'] as String,
      wipLimit: map['wipLimit'] as int?,
      enabled: map['enabled'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> _columnToMap(BoardColumnConfig column) {
    return {
      'id': column.id,
      'title': column.title,
      'wipLimit': column.wipLimit,
      'enabled': column.enabled,
    };
  }

  static BoardFilter _filterFromMap(Map<String, dynamic> map) {
    return BoardFilter(
      priorities: ((map['priorities'] as List<dynamic>?) ?? const [])
          .cast<String>()
          .toSet(),
      assignee: map['assignee'] as String? ?? '',
      tag: map['tag'] as String? ?? '',
    );
  }

  static Map<String, dynamic> _filterToMap(BoardFilter filter) {
    return {
      'priorities': filter.priorities.toList(),
      'assignee': filter.assignee,
      'tag': filter.tag,
    };
  }
}
