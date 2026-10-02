import '../../../../core/utils/result.dart';
import '../../../sprints/domain/entities/sprint.dart';
import '../../../sprints/domain/repositories/sprint_repository.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import '../entities/project_workspace.dart';
import '../repositories/project_repository.dart';

class GetProjectWorkspace {
  final ProjectRepository projectRepository;
  final SprintRepository sprintRepository;
  final TaskRepository taskRepository;

  GetProjectWorkspace(
    this.projectRepository,
    this.sprintRepository,
    this.taskRepository,
  );

  Future<ApiResult<ProjectWorkspace>> call(int projectId) async {
    final (projectResult, sprintsResult, tasksResult) = await (
      projectRepository.getProjectById(projectId),
      sprintRepository.getSprintsByProject(projectId),
      taskRepository.getTasksByProject(projectId),
    ).wait;
    return switch ((projectResult, sprintsResult, tasksResult)) {
      (Error(:final failure), _, _) => Error(failure),
      (_, Error(:final failure), _) => Error(failure),
      (_, _, Error(:final failure)) => Error(failure),
      (
        Success(data: final project),
        Success(data: final sprints),
        Success(data: final tasks),
      ) =>
        Success(
          ProjectWorkspace(
            project: project,
            sprints: _withCounts(sprints, tasks),
            tasks: tasks,
          ),
        ),
    };
  }

  /// Derives sprint counts from the loaded tasks so they are always
  /// consistent, whichever data source produced them.
  List<Sprint> _withCounts(List<Sprint> sprints, List<Task> tasks) {
    return sprints.map((sprint) {
      final sprintTasks = tasks.where((t) => t.sprintId == sprint.id);
      return sprint.copyWith(
        totalTasks: sprintTasks.length,
        completedTasks: sprintTasks.where((t) => t.isDone).length,
      );
    }).toList();
  }
}
