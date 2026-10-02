import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/task.dart';
import '../models/task_model.dart';
import 'task_datasource.dart';

class TaskLocalDataSource implements TaskDataSource {
  final DatabaseHelper databaseHelper;

  TaskLocalDataSource({required this.databaseHelper});

  @override
  Future<List<Task>> getTasksByProject(int projectId) async {
    final db = await databaseHelper.database;
    final rows = await db.query(
      AppConstants.tableTasks,
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'id',
    );
    return rows.map(TaskModel.fromMap).toList();
  }

  @override
  Future<List<Task>> getTasksBySprint(int sprintId) async {
    final db = await databaseHelper.database;
    final rows = await db.query(
      AppConstants.tableTasks,
      where: 'sprint_id = ?',
      whereArgs: [sprintId],
      orderBy: 'id',
    );
    return rows.map(TaskModel.fromMap).toList();
  }

  @override
  Future<Task> getTaskById(int id) async {
    final db = await databaseHelper.database;
    final rows = await db.query(
      AppConstants.tableTasks,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) throw NotFoundException('Task $id not found');
    return TaskModel.fromMap(rows.first);
  }

  @override
  Future<Task> createTask(Task task) async {
    final db = await databaseHelper.database;
    final stamped = task.copyWith(createdAt: task.createdAt ?? DateTime.now());
    final id = await db.insert(
      AppConstants.tableTasks,
      TaskModel.toMap(stamped),
    );
    return stamped.copyWith(id: id);
  }

  @override
  Future<Task> updateTask(Task task) async {
    final db = await databaseHelper.database;
    final count = await db.update(
      AppConstants.tableTasks,
      TaskModel.toMap(task),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    if (count == 0) throw NotFoundException('Task ${task.id} not found');
    return task;
  }

  @override
  Future<void> deleteTask(int id) async {
    final db = await databaseHelper.database;
    await db.delete(AppConstants.tableTasks, where: 'id = ?', whereArgs: [id]);
  }
}
