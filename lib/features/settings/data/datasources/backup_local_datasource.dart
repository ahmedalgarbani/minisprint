import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';

/// Exports / imports the local SQLite database as JSON.
class BackupLocalDataSource {
  final DatabaseHelper databaseHelper;

  BackupLocalDataSource({required this.databaseHelper});

  /// Only these columns are ever written on restore. Keys in the backup file
  /// become SQL column names, so they must never be taken from the file as-is.
  static const _columns = {
    AppConstants.tableProjects: ['id', 'name', 'description', 'key'],
    AppConstants.tableSprints: [
      'id',
      'project_id',
      'name',
      'goal',
      'start_date',
      'end_date',
      'status',
    ],
    AppConstants.tableTasks: [
      'id',
      'project_id',
      'sprint_id',
      'title',
      'description',
      'status',
      'priority',
      'type',
      'story_points',
      'assignee',
      'tags',
      'created_at',
    ],
  };

  Future<String> exportData() async {
    final db = await databaseHelper.database;
    return jsonEncode({
      'version': AppConstants.databaseVersion,
      'timestamp': DateTime.now().toIso8601String(),
      'data': {for (final table in _columns.keys) table: await db.query(table)},
    });
  }

  Future<String> createBackupFile() async {
    final jsonData = await exportData();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${directory.path}/minisprint_backup_$timestamp.json');
    await file.writeAsString(jsonData);
    return file.path;
  }

  Future<String?> pickBackupFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    return result?.files.single.path;
  }

  Future<void> importFile(String filePath) async {
    final contents = await File(filePath).readAsString();
    await importJson(contents);
  }

  /// Replaces all data with the backup. Accepts v2 backups (tasks without
  /// `project_id`) and v3 backups. Throws [LocalStorageException] on invalid
  /// input, leaving existing data untouched.
  Future<void> importJson(String contents) async {
    final Map<String, List<Map<String, Object?>>> tables;
    try {
      final backup = jsonDecode(contents) as Map<String, dynamic>;
      final data = backup['data'] as Map<String, dynamic>;
      tables = {
        for (final table in _columns.keys)
          table: (data[table] as List? ?? const [])
              .cast<Map<String, dynamic>>()
              .map((row) => _sanitize(table, row))
              .toList(),
      };
    } catch (_) {
      throw const LocalStorageException('Invalid backup file');
    }

    _dropOrphans(tables);

    final db = await databaseHelper.database;
    await db.transaction((txn) async {
      await txn.delete(AppConstants.tableTasks);
      await txn.delete(AppConstants.tableSprints);
      await txn.delete(AppConstants.tableProjects);
      for (final table in _columns.keys) {
        for (final row in tables[table]!) {
          await txn.insert(
            table,
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
      await DatabaseHelper.normalizeActiveSprints(txn);
    });
  }

  /// Backups from before v3 can contain rows of deleted projects / sprints
  /// (foreign keys were not enforced). Apply the same clean-up as the v3
  /// migration so they do not violate today's constraints.
  void _dropOrphans(Map<String, List<Map<String, Object?>>> tables) {
    final projectIds = {
      for (final p in tables[AppConstants.tableProjects]!) p['id'],
    };
    final sprints = tables[AppConstants.tableSprints]!
      ..removeWhere((s) => !projectIds.contains(s['project_id']));
    final sprintProject = {for (final s in sprints) s['id']: s['project_id']};
    final tasks = tables[AppConstants.tableTasks]!;
    for (final task in tasks) {
      task['project_id'] ??= sprintProject[task['sprint_id']];
      task['type'] ??= 'task';
      if (!sprintProject.containsKey(task['sprint_id'])) {
        task['sprint_id'] = null;
      }
    }
    tasks.removeWhere((t) => !projectIds.contains(t['project_id']));
  }

  Map<String, Object?> _sanitize(String table, Map<String, dynamic> row) {
    return {
      for (final column in _columns[table]!)
        if (row.containsKey(column))
          column: switch (row[column]) {
            final String v => v,
            final num v => v,
            null => null,
            final other => throw FormatException('Bad value: $other'),
          },
    };
  }
}
