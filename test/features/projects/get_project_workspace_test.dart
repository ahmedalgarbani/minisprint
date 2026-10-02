import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/core/error/failure.dart';
import 'package:minisprint/core/utils/result.dart';
import 'package:minisprint/features/projects/domain/entities/project.dart';
import 'package:minisprint/features/projects/domain/usecases/get_project_workspace.dart';
import 'package:minisprint/features/sprints/domain/entities/sprint.dart';

import '../../helpers/fakes.dart';

void main() {
  const project = Project(id: 1, name: 'App', description: '');

  test(
    'combines project, sprints and tasks with derived sprint counts',
    () async {
      final useCase = GetProjectWorkspace(
        FakeProjectRepository([project]),
        FakeSprintRepository([sprint(id: 10, status: SprintStatus.active)]),
        FakeTaskRepository([
          task(id: 1, sprintId: 10, status: 'Done'),
          task(id: 2, sprintId: 10),
          task(id: 3),
        ]),
      );

      final workspace = (await useCase(1)).dataOrNull!;

      expect(workspace.sprints.single.totalTasks, 2);
      expect(workspace.sprints.single.completedTasks, 1);
      expect(workspace.backlogTasks.map((t) => t.id), [3]);
    },
  );

  test('returns the first failure', () async {
    final sprints = FakeSprintRepository()
      ..failWith = const NetworkFailure('x');
    final useCase = GetProjectWorkspace(
      FakeProjectRepository([project]),
      sprints,
      FakeTaskRepository(),
    );

    expect((await useCase(1)).failureOrNull, isA<NetworkFailure>());
  });
}
