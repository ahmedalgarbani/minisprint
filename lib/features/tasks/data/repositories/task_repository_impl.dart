import '../../../../core/error/error_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDataSource dataSource;

  TaskRepositoryImpl({required this.dataSource});

  @override
  Future<ApiResult<List<Task>>> getTasksByProject(int projectId) =>
      guard(() => dataSource.getTasksByProject(projectId));

  @override
  Future<ApiResult<List<Task>>> getTasksBySprint(int sprintId) =>
      guard(() => dataSource.getTasksBySprint(sprintId));

  @override
  Future<ApiResult<Task>> getTaskById(int id) =>
      guard(() => dataSource.getTaskById(id));

  @override
  Future<ApiResult<Task>> createTask(Task task) =>
      guard(() => dataSource.createTask(task));

  @override
  Future<ApiResult<Task>> updateTask(Task task) =>
      guard(() => dataSource.updateTask(task));

  @override
  Future<ApiResult<void>> deleteTask(int id) =>
      guard(() => dataSource.deleteTask(id));
}
