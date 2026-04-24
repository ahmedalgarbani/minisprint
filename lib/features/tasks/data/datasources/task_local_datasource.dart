import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getAllTasks();
  Future<List<TaskModel>> getTasksBySprint(int sprintId);
  Future<TaskModel> getTaskById(int id);
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(int id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final DatabaseHelper databaseHelper;

  TaskLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<TaskModel>> getAllTasks() async {
    final db = await databaseHelper.database;
    final results = await db.query(AppConstants.tableTasks);
    return results.map((map) => TaskModel.fromMap(map)).toList();
  }

  @override
  Future<List<TaskModel>> getTasksBySprint(int sprintId) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      AppConstants.tableTasks,
      where: 'sprint_id = ?',
      whereArgs: [sprintId],
    );
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  @override
  Future<TaskModel> getTaskById(int id) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      AppConstants.tableTasks,
      where: 'id = ?',
      whereArgs: [id],
    );
    return TaskModel.fromMap(maps.first);
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    final db = await databaseHelper.database;
    final id = await db.insert(AppConstants.tableTasks, task.toMap());
    return TaskModel(
      id: id,
      sprintId: task.sprintId,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
    );
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    final db = await databaseHelper.database;
    await db.update(
      AppConstants.tableTasks,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return task;
  }

  @override
  Future<void> deleteTask(int id) async {
    final db = await databaseHelper.database;
    await db.delete(AppConstants.tableTasks, where: 'id = ?', whereArgs: [id]);
  }
}
