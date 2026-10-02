import 'package:minisprint/core/error/failure.dart';
import 'package:minisprint/core/utils/result.dart';
import 'package:minisprint/features/projects/domain/entities/project.dart';
import 'package:minisprint/features/projects/domain/repositories/project_repository.dart';
import 'package:minisprint/features/sprints/domain/entities/sprint.dart';
import 'package:minisprint/features/sprints/domain/repositories/sprint_repository.dart';
import 'package:minisprint/features/tasks/domain/entities/task.dart';
import 'package:minisprint/features/tasks/domain/repositories/task_repository.dart';

/// In-memory repositories for domain and cubit tests.
class FakeProjectRepository implements ProjectRepository {
  final Map<int, Project> projects;
  Failure? failWith;

  FakeProjectRepository([List<Project> initial = const []])
    : projects = {for (final p in initial) p.id!: p};

  @override
  Future<ApiResult<List<Project>>> getAllProjects() async =>
      failWith != null ? Error(failWith!) : Success(projects.values.toList());

  @override
  Future<ApiResult<Project>> getProjectById(int id) async {
    if (failWith != null) return Error(failWith!);
    final project = projects[id];
    return project == null
        ? const Error(NotFoundFailure('missing'))
        : Success(project);
  }

  @override
  Future<ApiResult<Project>> createProject(Project project) async {
    final created = project.copyWith(id: projects.length + 1);
    projects[created.id!] = created;
    return Success(created);
  }

  @override
  Future<ApiResult<Project>> updateProject(Project project) async {
    projects[project.id!] = project;
    return Success(project);
  }

  @override
  Future<ApiResult<void>> deleteProject(int id) async {
    projects.remove(id);
    return const Success(null);
  }
}

class FakeSprintRepository implements SprintRepository {
  final Map<int, Sprint> sprints;
  Failure? failWith;
  int _nextId = 100;

  FakeSprintRepository([List<Sprint> initial = const []])
    : sprints = {for (final s in initial) s.id!: s};

  @override
  Future<ApiResult<List<Sprint>>> getSprintsByProject(int projectId) async {
    if (failWith != null) return Error(failWith!);
    return Success(
      sprints.values.where((s) => s.projectId == projectId).toList(),
    );
  }

  @override
  Future<ApiResult<Sprint>> getSprintById(int id) async =>
      Success(sprints[id]!);

  @override
  Future<ApiResult<Sprint>> createSprint(Sprint sprint) async {
    final created = sprint.copyWith(id: _nextId++);
    sprints[created.id!] = created;
    return Success(created);
  }

  @override
  Future<ApiResult<Sprint>> updateSprint(Sprint sprint) async {
    if (failWith != null) return Error(failWith!);
    sprints[sprint.id!] = sprint;
    return Success(sprint);
  }

  @override
  Future<ApiResult<void>> deleteSprint(int id) async {
    sprints.remove(id);
    return const Success(null);
  }
}

class FakeTaskRepository implements TaskRepository {
  final Map<int, Task> tasks;
  Failure? failUpdatesWith;
  int _nextId = 1000;
  int updateCalls = 0;

  FakeTaskRepository([List<Task> initial = const []])
    : tasks = {for (final t in initial) t.id!: t};

  @override
  Future<ApiResult<List<Task>>> getTasksByProject(int projectId) async =>
      Success(tasks.values.where((t) => t.projectId == projectId).toList());

  @override
  Future<ApiResult<List<Task>>> getTasksBySprint(int sprintId) async =>
      Success(tasks.values.where((t) => t.sprintId == sprintId).toList());

  @override
  Future<ApiResult<Task>> getTaskById(int id) async => Success(tasks[id]!);

  @override
  Future<ApiResult<Task>> createTask(Task task) async {
    final created = task.copyWith(id: _nextId++);
    tasks[created.id!] = created;
    return Success(created);
  }

  @override
  Future<ApiResult<Task>> updateTask(Task task) async {
    updateCalls++;
    if (failUpdatesWith != null) return Error(failUpdatesWith!);
    tasks[task.id!] = task;
    return Success(task);
  }

  @override
  Future<ApiResult<void>> deleteTask(int id) async {
    tasks.remove(id);
    return const Success(null);
  }
}

Sprint sprint({
  required int id,
  int projectId = 1,
  SprintStatus status = SprintStatus.planned,
  String name = 'Sprint',
  DateTime? start,
  DateTime? end,
}) {
  final startDate = start ?? DateTime(2026, 1, 1);
  return Sprint(
    id: id,
    projectId: projectId,
    name: name,
    startDate: startDate,
    endDate: end ?? startDate.add(const Duration(days: 14)),
    status: status,
  );
}

Task task({
  required int id,
  int projectId = 1,
  int? sprintId,
  String title = 'Task',
  String status = 'To Do',
  String priority = 'Medium',
  WorkItemType type = WorkItemType.task,
  int? points,
  String assignee = '',
  List<String> tags = const [],
}) {
  return Task(
    id: id,
    projectId: projectId,
    sprintId: sprintId,
    title: title,
    status: status,
    priority: priority,
    type: type,
    storyPoints: points,
    assignee: assignee,
    tags: tags,
  );
}
