import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/core/constants/app_constants.dart';

import '../helpers/test_database.dart';

void main() {
  late TestDatabase testDb;

  setUp(() async => testDb = await TestDatabase.create());
  tearDown(() => testDb.dispose());

  /// Recreates the exact v2 schema shipped before this change.
  Future<void> seedVersion2() async {
    final db = await testDb.factory.openDatabase(testDb.path);
    await db.execute(
      'CREATE TABLE projects (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT)',
    );
    await db.execute(
      'CREATE TABLE sprints (id INTEGER PRIMARY KEY AUTOINCREMENT, project_id INTEGER NOT NULL, name TEXT NOT NULL, start_date TEXT NOT NULL, end_date TEXT NOT NULL, status TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, sprint_id INTEGER NOT NULL, title TEXT NOT NULL, description TEXT, status TEXT NOT NULL, priority TEXT NOT NULL, assignee TEXT, tags TEXT)',
    );
    await db.insert('projects', {'id': 1, 'name': 'App', 'description': ''});
    await db.insert('sprints', {
      'id': 10,
      'project_id': 1,
      'name': 'S1',
      'start_date': '2026-01-01T00:00:00.000',
      'end_date': '2026-01-15T00:00:00.000',
      'status': 'Active',
    });
    // Orphan sprint of a deleted project (foreign keys were not enforced).
    await db.insert('sprints', {
      'id': 11,
      'project_id': 99,
      'name': 'Orphan',
      'start_date': '2026-01-01T00:00:00.000',
      'end_date': '2026-01-15T00:00:00.000',
      'status': 'Active',
    });
    await db.insert('tasks', {
      'id': 5,
      'sprint_id': 10,
      'title': 'Login',
      'status': 'Done',
      'priority': 'High',
      'assignee': 'Sara',
      'tags': 'api,ui',
    });
    await db.insert('tasks', {
      'id': 6,
      'sprint_id': 11,
      'title': 'Lost',
      'status': 'To Do',
      'priority': 'Low',
    });
    await db.execute('PRAGMA user_version = 2');
    await db.close();
  }

  test(
    'upgrading v2 → v3 keeps tasks and links them to their project',
    () async {
      await seedVersion2();

      final db = await testDb.helper().database;
      final tasks = await db.query(AppConstants.tableTasks);

      final version = await db.rawQuery('PRAGMA user_version');
      expect(version.single.values.single, 3);
      expect(tasks, hasLength(1));
      expect(tasks.single['id'], 5);
      expect(tasks.single['project_id'], 1);
      expect(tasks.single['sprint_id'], 10);
      expect(tasks.single['type'], 'task');
      expect(tasks.single['assignee'], 'Sara');
    },
  );

  test('upgrading removes sprints of deleted projects', () async {
    await seedVersion2();

    final db = await testDb.helper().database;
    final sprints = await db.query(AppConstants.tableSprints);

    expect(sprints.map((s) => s['id']), [10]);
  });

  test('foreign keys are enforced after opening', () async {
    final db = await testDb.helper().database;
    final result = await db.rawQuery('PRAGMA foreign_keys');
    expect(result.single.values.single, 1);
  });

  test('upgrading keeps only the latest active sprint per project', () async {
    await seedVersion2();
    final db = await testDb.factory.openDatabase(testDb.path);
    await db.insert('sprints', {
      'id': 12,
      'project_id': 1,
      'name': 'S2',
      'start_date': '2026-02-01T00:00:00.000',
      'end_date': '2026-02-15T00:00:00.000',
      'status': 'Active',
    });
    await db.close();

    final upgraded = await testDb.helper().database;
    final rows = await upgraded.query(AppConstants.tableSprints, orderBy: 'id');

    expect(rows.map((r) => (r['id'], r['status'])), [
      (10, 'Planned'),
      (12, 'Active'),
    ]);
  });
}
