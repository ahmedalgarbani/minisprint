import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/features/projects/domain/entities/project.dart';
import 'package:minisprint/features/projects/domain/entities/project_workspace.dart';
import 'package:minisprint/features/sprints/domain/entities/sprint.dart';

import '../../helpers/fakes.dart';

void main() {
  ProjectWorkspace workspace(List<Sprint> sprints) => ProjectWorkspace(
    project: const Project(id: 1, name: 'App', description: ''),
    sprints: sprints,
    tasks: const [],
  );

  test('default board sprint is the active sprint', () {
    final ws = workspace([
      sprint(id: 1, status: SprintStatus.planned, start: DateTime(2026, 1, 1)),
      sprint(id: 2, status: SprintStatus.active, start: DateTime(2026, 2, 1)),
    ]);
    expect(ws.defaultBoardSprint?.id, 2);
  });

  test('default board sprint falls back to the earliest planned sprint', () {
    final ws = workspace([
      sprint(id: 1, status: SprintStatus.planned, start: DateTime(2026, 3, 1)),
      sprint(id: 2, status: SprintStatus.planned, start: DateTime(2026, 2, 1)),
      sprint(id: 3, status: SprintStatus.completed),
    ]);
    expect(ws.defaultBoardSprint?.id, 2);
  });

  test('there is no default board sprint when all sprints are completed', () {
    final ws = workspace([sprint(id: 3, status: SprintStatus.completed)]);
    expect(ws.defaultBoardSprint, isNull);
  });
}
