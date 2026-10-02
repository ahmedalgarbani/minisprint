import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/features/tasks/data/models/board_config_model.dart';
import 'package:minisprint/features/tasks/domain/entities/board_config.dart';
import 'package:minisprint/features/tasks/domain/entities/task.dart';

void main() {
  test('round-trips through JSON', () {
    const config = BoardConfig(
      columns: [
        BoardColumnConfig(id: 'QA', title: 'QA', wipLimit: 2, enabled: false),
      ],
      filter: BoardFilter(
        priorities: {'High'},
        types: {WorkItemType.bug},
        assignee: 'a',
        tag: 't',
      ),
      sortField: BoardSortField.storyPoints,
      sortDirection: SortDirection.ascending,
      grouping: BoardGrouping.type,
    );
    expect(BoardConfigModel.fromJson(BoardConfigModel.toJson(config)), config);
  });

  test('unknown enum names fall back to defaults', () {
    final config = BoardConfigModel.fromMap({
      'sortField': 'nope',
      'grouping': 'nope',
      'columns': <dynamic>[],
    });
    expect(config.sortField, BoardSortField.priority);
    expect(config.grouping, BoardGrouping.none);
    expect(config.columns, BoardConfig.advancedColumns);
  });
}
