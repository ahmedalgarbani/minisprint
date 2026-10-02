import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/core/constants/app_constants.dart';
import 'package:minisprint/core/error/exceptions.dart';
import 'package:minisprint/features/settings/data/datasources/backup_local_datasource.dart';

import '../../helpers/test_database.dart';

void main() {
  late TestDatabase testDb;
  late BackupLocalDataSource backup;

  setUp(() async {
    testDb = await TestDatabase.create();
    backup = BackupLocalDataSource(databaseHelper: testDb.helper());
  });
  tearDown(() => testDb.dispose());

  String v2Backup({Map<String, dynamic>? extraTaskFields}) => jsonEncode({
    'version': 2,
    'data': {
      'projects': [
        {'id': 1, 'name': 'App', 'description': ''},
      ],
      'sprints': [
        {
          'id': 10,
          'project_id': 1,
          'name': 'S1',
          'start_date': '2026-01-01',
          'end_date': '2026-01-15',
          'status': 'Active',
        },
      ],
      'tasks': [
        {
          'id': 5,
          'sprint_id': 10,
          'title': 'Login',
          'status': 'Done',
          'priority': 'High',
          ...?extraTaskFields,
        },
      ],
    },
  });

  test('imports a v2 backup and links tasks to their project', () async {
    await backup.importJson(v2Backup());

    final db = await testDb.helper().database;
    final task = (await db.query(AppConstants.tableTasks)).single;
    expect(task['project_id'], 1);
    expect(task['type'], 'task');
  });

  test('export then import restores the same data', () async {
    await backup.importJson(v2Backup());
    final exported = await backup.exportData();

    await backup.importJson(exported);

    final db = await testDb.helper().database;
    expect(await db.query(AppConstants.tableTasks), hasLength(1));
    expect(await db.query(AppConstants.tableProjects), hasLength(1));
  });

  test('ignores unknown keys so they never become SQL column names', () async {
    await backup.importJson(
      v2Backup(
        extraTaskFields: {'title) VALUES (1); DROP TABLE tasks; --': 'x'},
      ),
    );

    final db = await testDb.helper().database;
    expect(await db.query(AppConstants.tableTasks), hasLength(1));
  });

  test('rejects malformed files and keeps existing data', () async {
    await backup.importJson(v2Backup());

    await expectLater(
      backup.importJson('{"data": 1}'),
      throwsA(isA<LocalStorageException>()),
    );

    final db = await testDb.helper().database;
    expect(await db.query(AppConstants.tableProjects), hasLength(1));
  });

  // Regression: v2 backups can contain rows of deleted projects/sprints,
  // which made the whole restore fail under enforced foreign keys.
  test('drops orphan rows from old backups instead of failing', () async {
    await backup.importJson(
      jsonEncode({
        'version': 2,
        'data': {
          'projects': [
            {'id': 1, 'name': 'App', 'description': ''},
          ],
          'sprints': [
            {
              'id': 10,
              'project_id': 1,
              'name': 'S1',
              'start_date': '2026-01-01',
              'end_date': '2026-01-15',
              'status': 'Active',
            },
            {
              'id': 11,
              'project_id': 99,
              'name': 'Orphan',
              'start_date': '2026-01-01',
              'end_date': '2026-01-15',
              'status': 'Active',
            },
          ],
          'tasks': [
            {
              'id': 1,
              'sprint_id': 10,
              'title': 'Kept',
              'status': 'To Do',
              'priority': 'Low',
            },
            {
              'id': 2,
              'sprint_id': 11,
              'title': 'Sprint of deleted project',
              'status': 'To Do',
              'priority': 'Low',
            },
            {
              'id': 3,
              'project_id': 1,
              'sprint_id': 404,
              'title': 'Deleted sprint',
              'status': 'To Do',
              'priority': 'Low',
            },
          ],
        },
      }),
    );

    final db = await testDb.helper().database;
    final tasks = await db.query(AppConstants.tableTasks, orderBy: 'id');
    expect(tasks.map((t) => (t['id'], t['sprint_id'])), [(1, 10), (3, null)]);
    expect(await db.query(AppConstants.tableSprints), hasLength(1));
  });
}
