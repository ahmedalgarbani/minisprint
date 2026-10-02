import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/core/error/exceptions.dart';
import 'package:minisprint/features/projects/data/datasources/project_local_datasource.dart';
import 'package:minisprint/features/projects/domain/entities/project.dart';
import 'package:minisprint/features/sprints/data/datasources/sprint_local_datasource.dart';
import 'package:minisprint/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:minisprint/features/tasks/domain/entities/task.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_database.dart';

void main() {
  late TestDatabase testDb;
  late ProjectLocalDataSource projects;
  late SprintLocalDataSource sprints;
  late TaskLocalDataSource tasks;

  setUp(() async {
    testDb = await TestDatabase.create();
    final helper = testDb.helper();
    projects = ProjectLocalDataSource(databaseHelper: helper);
    sprints = SprintLocalDataSource(databaseHelper: helper);
    tasks = TaskLocalDataSource(databaseHelper: helper);
  });
  tearDown(() => testDb.dispose());

  Future<(int, int)> seed() async {
    final project = await projects.createProject(
      const Project(name: 'App', description: ''),
    );
    final created = await sprints.createSprint(
      sprint(id: 0, projectId: project.id!).copyWith(id: null),
    );
    return (project.id!, created.id!);
  }

  // Regression: foreign keys were never enabled, so deleting a project left
  // its sprints and tasks behind.
  test('deleting a project deletes its sprints and tasks', () async {
    final (projectId, sprintId) = await seed();
    await tasks.createTask(
      Task(projectId: projectId, sprintId: sprintId, title: 'A'),
    );

    await projects.deleteProject(projectId);

    expect(await sprints.getSprintsByProject(projectId), isEmpty);
    expect(await tasks.getTasksByProject(projectId), isEmpty);
  });

  test('deleting a sprint moves its tasks to the backlog', () async {
    final (projectId, sprintId) = await seed();
    await tasks.createTask(
      Task(projectId: projectId, sprintId: sprintId, title: 'A'),
    );

    await sprints.deleteSprint(sprintId);

    final remaining = await tasks.getTasksByProject(projectId);
    expect(remaining.single.sprintId, isNull);
  });

  test('round-trips all task fields', () async {
    final (projectId, sprintId) = await seed();
    final created = await tasks.createTask(
      Task(
        projectId: projectId,
        sprintId: sprintId,
        title: 'Login',
        type: WorkItemType.bug,
        storyPoints: 5,
        assignee: 'Sara',
        tags: const ['api'],
      ),
    );

    final loaded = await tasks.getTaskById(created.id!);

    expect(loaded, created);
    expect(loaded.createdAt, isNotNull);
  });

  test('project counts include backlog tasks', () async {
    final (projectId, _) = await seed();
    await tasks.createTask(Task(projectId: projectId, title: 'Backlog item'));

    final project = await projects.getProjectById(projectId);

    expect(project.sprintCount, 1);
    expect(project.taskCount, 1);
  });

  test('missing rows throw NotFoundException', () async {
    expect(projects.getProjectById(404), throwsA(isA<NotFoundException>()));
    expect(tasks.getTaskById(404), throwsA(isA<NotFoundException>()));
  });
}
