import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../database/database_helper.dart';
import '../constants/app_constants.dart';

class BackupDataSource {
  final DatabaseHelper _databaseHelper;

  BackupDataSource({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  Future<String> exportData() async {
    final db = await _databaseHelper.database;

    final projects = await db.query(AppConstants.tableProjects);
    final sprints = await db.query(AppConstants.tableSprints);
    final tasks = await db.query(AppConstants.tableTasks);

    final backup = {
      'version': AppConstants.databaseVersion,
      'timestamp': DateTime.now().toIso8601String(),
      'data': {
        AppConstants.tableProjects: projects,
        AppConstants.tableSprints: sprints,
        AppConstants.tableTasks: tasks,
      },
    };

    return jsonEncode(backup);
  }

  Future<File> createBackupFile() async {
    final jsonData = await exportData();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${directory.path}/minisprint_backup_$timestamp.json');
    return file.writeAsString(jsonData);
  }

  Future<String?> pickBackupFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    return result?.files.single.path;
  }

  Future<bool> importData(String filePath) async {
    try {
      final file = File(filePath);
      final jsonData = await file.readAsString();
      final backup = jsonDecode(jsonData) as Map<String, dynamic>;

      final data = backup['data'] as Map<String, dynamic>;
      final db = await _databaseHelper.database;

      await db.transaction((txn) async {
        await txn.delete(AppConstants.tableTasks);
        await txn.delete(AppConstants.tableSprints);
        await txn.delete(AppConstants.tableProjects);

        final projects = data[AppConstants.tableProjects] as List;
        for (final project in projects) {
          await txn.insert(
            AppConstants.tableProjects,
            Map<String, dynamic>.from(project),
          );
        }

        final sprints = data[AppConstants.tableSprints] as List;
        for (final sprint in sprints) {
          await txn.insert(
            AppConstants.tableSprints,
            Map<String, dynamic>.from(sprint),
          );
        }

        final tasks = data[AppConstants.tableTasks] as List;
        for (final task in tasks) {
          await txn.insert(
            AppConstants.tableTasks,
            Map<String, dynamic>.from(task),
          );
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
