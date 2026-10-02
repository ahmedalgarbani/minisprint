import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_utils.dart';
import '../../domain/entities/task.dart';
import '../models/task_model.dart';
import 'task_datasource.dart';

class TaskRemoteDataSource implements TaskDataSource {
  final ApiClient client;

  TaskRemoteDataSource({required this.client});

  @override
  Future<List<Task>> getTasksByProject(int projectId) async {
    final body = await client.get('/projects/$projectId/tasks');
    return jsonList(body).map(TaskModel.fromMap).toList();
  }

  @override
  Future<List<Task>> getTasksBySprint(int sprintId) async {
    final body = await client.get('/sprints/$sprintId/tasks');
    return jsonList(body).map(TaskModel.fromMap).toList();
  }

  @override
  Future<Task> getTaskById(int id) async {
    final body = await client.get('/tasks/$id');
    return TaskModel.fromMap(jsonObject(body));
  }

  @override
  Future<Task> createTask(Task task) async {
    final body = await client.post('/tasks', body: TaskModel.toJson(task));
    return TaskModel.fromMap(jsonObject(body));
  }

  @override
  Future<Task> updateTask(Task task) async {
    final body = await client.put(
      '/tasks/${task.id}',
      body: TaskModel.toJson(task),
    );
    return body == null ? task : TaskModel.fromMap(jsonObject(body));
  }

  @override
  Future<void> deleteTask(int id) => client.delete('/tasks/$id');
}
