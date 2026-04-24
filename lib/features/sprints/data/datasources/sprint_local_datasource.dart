import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../models/sprint_model.dart';

abstract class SprintLocalDataSource {
  Future<List<SprintModel>> getAllSprints();
  Future<List<SprintModel>> getSprintsByProject(int projectId);
  Future<SprintModel> getSprintById(int id);
  Future<SprintModel> createSprint(SprintModel sprint);
  Future<SprintModel> updateSprint(SprintModel sprint);
  Future<void> deleteSprint(int id);
}

class SprintLocalDataSourceImpl implements SprintLocalDataSource {
  final DatabaseHelper databaseHelper;

  SprintLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<SprintModel>> getAllSprints() async {
    final db = await databaseHelper.database;
    final results = await db.rawQuery('''
      SELECT s.*, 
             (SELECT COUNT(*) FROM ${AppConstants.tableTasks} t WHERE t.sprint_id = s.id) as total_tasks,
             (SELECT COUNT(*) FROM ${AppConstants.tableTasks} t WHERE t.sprint_id = s.id AND t.status = 'Done') as completed_tasks
      FROM ${AppConstants.tableSprints} s
    ''');
    return results.map((map) => SprintModel.fromMap(map)).toList();
  }

  @override
  Future<List<SprintModel>> getSprintsByProject(int projectId) async {
    final db = await databaseHelper.database;
    final results = await db.rawQuery('''
      SELECT s.*, 
             (SELECT COUNT(*) FROM ${AppConstants.tableTasks} t WHERE t.sprint_id = s.id) as total_tasks,
             (SELECT COUNT(*) FROM ${AppConstants.tableTasks} t WHERE t.sprint_id = s.id AND t.status = 'Done') as completed_tasks
      FROM ${AppConstants.tableSprints} s
      WHERE s.project_id = ?
    ''', [projectId]);
    return results.map((map) => SprintModel.fromMap(map)).toList();
  }

  @override
  Future<SprintModel> getSprintById(int id) async {
    final db = await databaseHelper.database;
    final results = await db.rawQuery('''
      SELECT s.*, 
             (SELECT COUNT(*) FROM ${AppConstants.tableTasks} t WHERE t.sprint_id = s.id) as total_tasks,
             (SELECT COUNT(*) FROM ${AppConstants.tableTasks} t WHERE t.sprint_id = s.id AND t.status = 'Done') as completed_tasks
      FROM ${AppConstants.tableSprints} s
      WHERE s.id = ?
    ''', [id]);
    return SprintModel.fromMap(results.first);
  }

  @override
  Future<SprintModel> createSprint(SprintModel sprint) async {
    final db = await databaseHelper.database;
    final id = await db.insert(AppConstants.tableSprints, sprint.toMap());
    return SprintModel(
      id: id,
      projectId: sprint.projectId,
      name: sprint.name,
      startDate: sprint.startDate,
      endDate: sprint.endDate,
      status: sprint.status,
    );
  }

  @override
  Future<SprintModel> updateSprint(SprintModel sprint) async {
    final db = await databaseHelper.database;
    await db.update(
      AppConstants.tableSprints,
      sprint.toMap(),
      where: 'id = ?',
      whereArgs: [sprint.id],
    );
    return sprint;
  }

  @override
  Future<void> deleteSprint(int id) async {
    final db = await databaseHelper.database;
    await db.delete(
      AppConstants.tableSprints,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
