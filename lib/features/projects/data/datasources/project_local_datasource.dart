import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../models/project_model.dart';

abstract class ProjectLocalDataSource {
  Future<List<ProjectModel>> getAllProjects();
  Future<ProjectModel> getProjectById(int id);
  Future<ProjectModel> createProject(ProjectModel project);
  Future<ProjectModel> updateProject(ProjectModel project);
  Future<void> deleteProject(int id);
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  final DatabaseHelper databaseHelper;

  ProjectLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<ProjectModel>> getAllProjects() async {
    final db = await databaseHelper.database;
    final results = await db.rawQuery('''
      SELECT p.*, 
             (SELECT COUNT(*) FROM ${AppConstants.tableSprints} s WHERE s.project_id = p.id) as sprint_count,
             (SELECT COUNT(*) FROM ${AppConstants.tableTasks} t 
              JOIN ${AppConstants.tableSprints} s ON s.id = t.sprint_id 
              WHERE s.project_id = p.id) as task_count
      FROM ${AppConstants.tableProjects} p
    ''');
    return results.map((map) => ProjectModel.fromMap(map)).toList();
  }

  @override
  Future<ProjectModel> getProjectById(int id) async {
    final db = await databaseHelper.database;
    final results = await db.rawQuery('''
      SELECT p.*, 
             (SELECT COUNT(*) FROM ${AppConstants.tableSprints} s WHERE s.project_id = p.id) as sprint_count,
             (SELECT COUNT(*) FROM ${AppConstants.tableTasks} t 
              JOIN ${AppConstants.tableSprints} s ON s.id = t.sprint_id 
              WHERE s.project_id = p.id) as task_count
      FROM ${AppConstants.tableProjects} p
      WHERE p.id = ?
    ''', [id]);
    return ProjectModel.fromMap(results.first);
  }

  @override
  Future<ProjectModel> createProject(ProjectModel project) async {
    final db = await databaseHelper.database;
    final id = await db.insert(AppConstants.tableProjects, project.toMap());
    return ProjectModel(
      id: id,
      name: project.name,
      description: project.description,
    );
  }

  @override
  Future<ProjectModel> updateProject(ProjectModel project) async {
    final db = await databaseHelper.database;
    await db.update(
      AppConstants.tableProjects,
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
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
