import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/sprint.dart';
import '../models/sprint_model.dart';
import 'sprint_datasource.dart';

class SprintLocalDataSource implements SprintDataSource {
  final DatabaseHelper databaseHelper;

  SprintLocalDataSource({required this.databaseHelper});

  static const _selectWithCounts =
      '''
    SELECT s.*,
      (SELECT COUNT(*) FROM ${AppConstants.tableTasks} t WHERE t.sprint_id = s.id) AS total_tasks,
      (SELECT COUNT(*) FROM ${AppConstants.tableTasks} t
        WHERE t.sprint_id = s.id AND t.status = '${TaskStatus.done}') AS completed_tasks
    FROM ${AppConstants.tableSprints} s
  ''';

  @override
  Future<List<Sprint>> getSprintsByProject(int projectId) async {
    final db = await databaseHelper.database;
    final rows = await db.rawQuery(
      '$_selectWithCounts WHERE s.project_id = ? ORDER BY s.start_date, s.id',
      [projectId],
    );
    return rows.map(SprintModel.fromMap).toList();
  }

  @override
  Future<Sprint> getSprintById(int id) async {
    final db = await databaseHelper.database;
    final rows = await db.rawQuery('$_selectWithCounts WHERE s.id = ?', [id]);
    if (rows.isEmpty) throw NotFoundException('Sprint $id not found');
    return SprintModel.fromMap(rows.first);
  }

  @override
  Future<Sprint> createSprint(Sprint sprint) async {
    final db = await databaseHelper.database;
    final id = await db.insert(
      AppConstants.tableSprints,
      SprintModel.toMap(sprint),
    );
    return sprint.copyWith(id: id);
  }

  @override
  Future<Sprint> updateSprint(Sprint sprint) async {
    final db = await databaseHelper.database;
    final count = await db.update(
      AppConstants.tableSprints,
      SprintModel.toMap(sprint),
      where: 'id = ?',
      whereArgs: [sprint.id],
    );
    if (count == 0) throw NotFoundException('Sprint ${sprint.id} not found');
    return sprint;
  }

  @override
  Future<void> deleteSprint(int id) async {
    final db = await databaseHelper.database;
    // ON DELETE SET NULL on tasks.sprint_id moves the tasks to the backlog.
    await db.delete(
      AppConstants.tableSprints,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
