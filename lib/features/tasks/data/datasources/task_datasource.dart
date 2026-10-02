import '../../domain/entities/task.dart';

/// Contract shared by the local (SQLite) and remote (REST) implementations.
abstract class TaskDataSource {
  /// All tasks of a project: backlog and every sprint.
  Future<List<Task>> getTasksByProject(int projectId);
  Future<List<Task>> getTasksBySprint(int sprintId);
  Future<Task> getTaskById(int id);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(int id);
}
