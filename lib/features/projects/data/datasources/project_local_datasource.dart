import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/project.dart';
import '../models/project_model.dart';
import 'project_datasource.dart';

class ProjectLocalDataSource implements ProjectDataSource {
  final DatabaseHelper databaseHelper;

  ProjectLocalDataSource({required this.databaseHelper});

  static const _selectWithCounts =
      '''
    SELECT p.*,
      (SELECT COUNT(*) FROM ${AppConstants.tableSprints} s WHERE s.project_id = p.id) AS sprint_count,
      (SELECT COUNT(*) FROM ${AppConstants.tableTasks} t WHERE t.project_id = p.id) AS task_count
    FROM ${AppConstants.tableProjects} p
  ''';

  @override
  Future<List<Project>> getAllProjects() async {
    final db = await databaseHelper.database;
    final rows = await db.rawQuery('$_selectWithCounts ORDER BY p.id DESC');
    return rows.map(ProjectModel.fromMap).toList();
  }

  @override
  Future<Project> getProjectById(int id) async {
    final db = await databaseHelper.database;
    final rows = await db.rawQuery('$_selectWithCounts WHERE p.id = ?', [id]);
    if (rows.isEmpty) throw NotFoundException('Project $id not found');
    return ProjectModel.fromMap(rows.first);
  }

  @override
  Future<Project> createProject(Project project) async {
    final db = await databaseHelper.database;
    final id = await db.insert(
      AppConstants.tableProjects,
      ProjectModel.toMap(project),
    );
    return project.copyWith(id: id);
  }

  @override
  Future<Project> updateProject(Project project) async {
    final db = await databaseHelper.database;
    final count = await db.update(
      AppConstants.tableProjects,
      ProjectModel.toMap(project),
      where: 'id = ?',
      whereArgs: [project.id],
    );
    if (count == 0) throw NotFoundException('Project ${project.id} not found');
    return project;
  }

  @override
  Future<void> deleteProject(int id) async {
    final db = await databaseHelper.database;
    await db.delete(
      AppConstants.tableProjects,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
