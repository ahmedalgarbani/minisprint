import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/features/projects/domain/entities/project.dart';
import 'package:minisprint/features/projects/domain/entities/project_workspace.dart';
import 'package:minisprint/features/reports/domain/entities/sprint_report.dart';
import 'package:minisprint/features/reports/domain/usecases/build_sprint_report.dart';
import 'package:minisprint/features/sprints/domain/entities/sprint.dart';
import 'package:minisprint/features/tasks/domain/entities/task.dart';

import '../../helpers/fakes.dart';

void main() {
  const build = BuildSprintReport();
  final active = sprint(
    id: 1,
    status: SprintStatus.active,
    start: DateTime(2026, 1, 1),
    end: DateTime(2026, 1, 11),
  );

  ProjectWorkspace workspace(List<Sprint> sprints, List<Task> tasks) =>
      ProjectWorkspace(
        project: const Project(id: 1, name: 'App', description: ''),
        sprints: sprints,
        tasks: tasks,
      );

  test('completion uses story points when the sprint is estimated', () {
    final report = build(
      workspace: workspace(
        [active],
        [
          task(id: 1, sprintId: 1, status: 'Done', points: 3),
          task(id: 2, sprintId: 1, points: 5),
          task(id: 3, sprintId: 1, status: 'Done'),
        ],
      ),
      sprint: active,
      now: DateTime(2026, 1, 6),
    );
    expect(report.totalPoints, 8);
    expect(report.donePoints, 3);
    expect(report.completion, 3 / 8);
    expect(report.doneTasks, 2);
  });

  test('completion falls back to task count without estimates', () {
    final report = build(
      workspace: workspace(
        [active],
        [task(id: 1, sprintId: 1, status: 'Done'), task(id: 2, sprintId: 1)],
      ),
      sprint: active,
      now: DateTime(2026, 1, 6),
    );
    expect(report.completion, 0.5);
  });

  test('flags a sprint at risk when work lags far behind time', () {
    final report = build(
      workspace: workspace(
        [active],
        [task(id: 1, sprintId: 1), task(id: 2, sprintId: 1)],
      ),
      sprint: active,
      now: DateTime(2026, 1, 9),
    );
    expect(report.timeElapsed, closeTo(0.8, 0.001));
    expect(report.health, ScheduleHealth.atRisk);
  });

  test('a sprint keeping pace with time is on track', () {
    final report = build(
      workspace: workspace(
        [active],
        [task(id: 1, sprintId: 1, status: 'Done'), task(id: 2, sprintId: 1)],
      ),
      sprint: active,
      now: DateTime(2026, 1, 6),
    );
    expect(report.health, ScheduleHealth.onTrack);
  });

  test('velocity lists done points of completed sprints, oldest first', () {
    final old = sprint(
      id: 2,
      status: SprintStatus.completed,
      name: 'S1',
      start: DateTime(2025, 12, 1),
      end: DateTime(2025, 12, 14),
    );
    final recent = sprint(
      id: 3,
      status: SprintStatus.completed,
      name: 'S2',
      start: DateTime(2025, 12, 15),
      end: DateTime(2025, 12, 28),
    );
    final report = build(
      workspace: workspace(
        [active, recent, old],
        [
          task(id: 1, sprintId: 2, status: 'Done', points: 5),
          task(id: 2, sprintId: 3, status: 'Done', points: 8),
          task(id: 3, sprintId: 3, points: 3),
        ],
      ),
      sprint: active,
      now: DateTime(2026, 1, 2),
    );
    expect(report.velocity.map((v) => (v.sprintName, v.donePoints)), [
      ('S1', 5),
      ('S2', 8),
    ]);
    expect(report.averageVelocity, 6.5);
  });

  test('workload lists unassigned work last', () {
    final report = build(
      workspace: workspace(
        [active],
        [task(id: 1, sprintId: 1), task(id: 2, sprintId: 1, assignee: 'Sara')],
      ),
      sprint: active,
      now: DateTime(2026, 1, 2),
    );
    expect(report.workload.map((w) => w.assignee), ['Sara', '']);
  });
}
