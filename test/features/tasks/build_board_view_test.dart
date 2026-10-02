import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/core/constants/app_constants.dart';
import 'package:minisprint/core/preferences/work_mode.dart';
import 'package:minisprint/features/tasks/domain/entities/board_config.dart';
import 'package:minisprint/features/tasks/domain/entities/task.dart';
import 'package:minisprint/features/tasks/domain/usecases/build_board_view.dart';

import '../../helpers/fakes.dart';

void main() {
  const build = BuildBoardView();

  group('resolveColumnId', () {
    const simple = BoardConfig.simpleColumns;

    test('matches the status exactly, ignoring case', () {
      expect(resolveColumnId('in progress', simple), TaskStatus.inProgress);
    });

    test('shows Review tasks in In Progress on the simple board', () {
      expect(resolveColumnId(TaskStatus.review, simple), TaskStatus.inProgress);
    });

    test('shows Backlog-status tasks in To Do', () {
      expect(resolveColumnId(TaskStatus.backlog, simple), TaskStatus.todo);
    });

    test('puts done tasks in the last column when Done is hidden', () {
      const columns = [
        BoardColumnConfig(id: 'To Do', title: 'To Do'),
        BoardColumnConfig(id: 'QA', title: 'QA'),
      ];
      expect(resolveColumnId(TaskStatus.done, columns), 'QA');
    });

    test('puts unknown statuses in the first column', () {
      expect(resolveColumnId('Blocked', simple), TaskStatus.todo);
    });
  });

  test('simple mode never hides tasks, even with custom statuses', () {
    final view = build(
      tasks: [
        task(id: 1, status: TaskStatus.review),
        task(id: 2, status: 'Blocked'),
        task(id: 3, status: TaskStatus.done),
      ],
      config: const BoardConfig(),
      mode: WorkMode.simple,
    );
    expect(view.visibleCount, 3);
    expect(view.countFor(TaskStatus.inProgress), 1);
    expect(view.countFor(TaskStatus.todo), 1);
    expect(view.countFor(TaskStatus.done), 1);
  });

  test('simple mode ignores saved advanced filters', () {
    final view = build(
      tasks: [task(id: 1, priority: 'Low')],
      config: const BoardConfig(filter: BoardFilter(priorities: {'High'})),
      mode: WorkMode.simple,
    );
    expect(view.visibleCount, 1);
  });

  test('advanced filters combine priority, type, assignee and tag', () {
    final view = build(
      tasks: [
        task(
          id: 1,
          priority: 'High',
          type: WorkItemType.bug,
          assignee: 'Sara Ali',
          tags: ['api'],
        ),
        task(
          id: 2,
          priority: 'High',
          type: WorkItemType.story,
          assignee: 'Sara Ali',
          tags: ['api'],
        ),
        task(
          id: 3,
          priority: 'Low',
          type: WorkItemType.bug,
          assignee: 'Sara Ali',
          tags: ['api'],
        ),
        task(
          id: 4,
          priority: 'High',
          type: WorkItemType.bug,
          assignee: 'Omar',
          tags: ['api'],
        ),
      ],
      config: const BoardConfig(
        filter: BoardFilter(
          priorities: {'High'},
          types: {WorkItemType.bug},
          assignee: 'sara',
          tag: 'AP',
        ),
      ),
      mode: WorkMode.advanced,
    );
    expect(view.visibleCount, 1);
    expect(view.lanes.single.cells[TaskStatus.todo]!.single.id, 1);
  });

  test('search matches the work item key', () {
    final view = build(
      tasks: [
        task(id: 12, title: 'A'),
        task(id: 3, title: 'B'),
      ],
      config: const BoardConfig(),
      mode: WorkMode.simple,
      query: 'mob-12',
      projectKey: 'MOB',
    );
    expect(view.visibleCount, 1);
    expect(view.isFiltered, isTrue);
  });

  test('sorts by priority descending with a stable id tie-break', () {
    final view = build(
      tasks: [
        task(id: 3, priority: 'Low'),
        task(id: 2, priority: 'High'),
        task(id: 1, priority: 'High'),
      ],
      config: const BoardConfig(),
      mode: WorkMode.advanced,
    );
    expect(view.lanes.single.cells[TaskStatus.todo]!.map((t) => t.id), [
      1,
      2,
      3,
    ]);
  });

  test('groups into swimlanes by assignee with unassigned last', () {
    final view = build(
      tasks: [
        task(id: 1, assignee: ''),
        task(id: 2, assignee: 'Zed'),
        task(id: 3, assignee: 'Amal'),
      ],
      config: const BoardConfig(grouping: BoardGrouping.assignee),
      mode: WorkMode.advanced,
    );
    expect(view.lanes.map((l) => l.value), ['Amal', 'Zed', '']);
  });

  test('flags columns over their WIP limit', () {
    final view = build(
      tasks: [
        for (var i = 1; i <= 4; i++) task(id: i, status: TaskStatus.review),
      ],
      config: const BoardConfig(),
      mode: WorkMode.advanced,
    );
    final review = view.columns.firstWhere((c) => c.id == TaskStatus.review);
    expect(view.isOverWipLimit(review), isTrue);
  });

  test('hidden columns are excluded from the advanced board', () {
    final view = build(
      tasks: const [],
      config: BoardConfig(
        columns: [
          for (final c in BoardConfig.advancedColumns)
            c.id == TaskStatus.review ? c.copyWith(enabled: false) : c,
        ],
      ),
      mode: WorkMode.advanced,
    );
    expect(view.columns.map((c) => c.id), isNot(contains(TaskStatus.review)));
    expect(view.lanes, hasLength(1));
  });

  // Regression: WIP counts came from the filtered list, so a filter could
  // hide an over-limit column.
  test('WIP counts include tasks hidden by filters', () {
    final view = build(
      tasks: [
        for (var i = 1; i <= 4; i++)
          task(id: i, status: TaskStatus.review, priority: 'Low'),
      ],
      config: const BoardConfig(filter: BoardFilter(priorities: {'High'})),
      mode: WorkMode.advanced,
    );
    final review = view.columns.firstWhere((c) => c.id == TaskStatus.review);
    expect(view.visibleCount, 0);
    expect(view.isOverWipLimit(review), isTrue);
  });
}
