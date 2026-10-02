import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/core/error/failure.dart';
import 'package:minisprint/features/projects/domain/entities/project.dart';
import 'package:minisprint/features/projects/domain/usecases/get_project_workspace.dart';
import 'package:minisprint/features/projects/presentation/cubit/project_workspace_cubit.dart';
import 'package:minisprint/features/projects/presentation/cubit/project_workspace_state.dart';
import 'package:minisprint/features/reports/domain/usecases/build_sprint_report.dart';
import 'package:minisprint/features/sprints/domain/entities/sprint.dart';
import 'package:minisprint/features/sprints/domain/usecases/sprint_usecases.dart';
import 'package:minisprint/features/tasks/domain/usecases/task_usecases.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeProjectRepository projects;
  late FakeSprintRepository sprints;
  late FakeTaskRepository tasks;
  late ProjectWorkspaceCubit cubit;

  setUp(() {
    projects = FakeProjectRepository([
      const Project(id: 1, name: 'App', description: ''),
    ]);
    sprints = FakeSprintRepository([
      sprint(id: 1, status: SprintStatus.active),
    ]);
    tasks = FakeTaskRepository([task(id: 1, sprintId: 1)]);
    cubit = ProjectWorkspaceCubit(
      getWorkspace: GetProjectWorkspace(projects, sprints, tasks),
      createTask: CreateTask(tasks),
      updateTask: UpdateTask(tasks),
      deleteTask: DeleteTask(tasks),
      moveTaskToSprint: MoveTaskToSprint(tasks),
      changeTaskStatus: ChangeTaskStatus(tasks),
      createSprint: CreateSprint(sprints),
      updateSprint: UpdateSprint(sprints),
      deleteSprint: DeleteSprint(sprints),
      startSprint: StartSprint(sprints),
      completeSprint: CompleteSprint(sprints, tasks),
      buildSprintReport: const BuildSprintReport(),
    );
  });
  tearDown(() => cubit.close());

  String statusOnScreen() =>
      (cubit.state as WorkspaceLoaded).workspace.tasks.single.status;

  test('selects the active sprint after loading', () async {
    await cubit.load(1);
    expect((cubit.state as WorkspaceLoaded).selectedSprintId, 1);
  });

  test('a successful drag keeps the new status', () async {
    await cubit.load(1);
    final failure = await cubit.changeStatus(tasks.tasks[1]!, 'Done');
    expect(failure, isNull);
    expect(statusOnScreen(), 'Done');
  });

  // Regression: when both the save and the reload failed, the optimistic
  // status stayed on screen.
  test('a failed drag snaps back even when reloading also fails', () async {
    await cubit.load(1);
    tasks.failUpdatesWith = const NetworkFailure('offline');
    projects.failWith = const NetworkFailure('offline');

    final failure = await cubit.changeStatus(tasks.tasks[1]!, 'Done');

    expect(failure, isA<NetworkFailure>());
    expect(statusOnScreen(), 'To Do');
  });
}
