import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';

class DatabaseHelper {
  final DatabaseFactory? _factory;
  final String? _path;
  Future<Database>? _database;

  /// [factory] and [path] are injectable so tests can use an in-memory
  /// database through `sqflite_common_ffi`.
  DatabaseHelper({DatabaseFactory? factory, String? path})
    : _factory = factory,
      _path = path;

  Future<Database> get database =>
      _database ??= _open().catchError((Object error) {
        // Do not cache a failed open; the next access retries.
        _database = null;
        throw error;
      });

  Future<Database> _open() async {
    final path =
        _path ?? join(await getDatabasesPath(), AppConstants.databaseName);
    final options = OpenDatabaseOptions(
      version: AppConstants.databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return (_factory ?? databaseFactory).openDatabase(path, options: options);
  }

  // SQLite ignores FOREIGN KEY clauses (and ON DELETE CASCADE) unless enabled
  // on every connection.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableProjects} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        key TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableSprints} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        goal TEXT NOT NULL DEFAULT '',
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES ${AppConstants.tableProjects}(id) ON DELETE CASCADE
      )
    ''');

    await _createTasksTable(db, AppConstants.tableTasks);
  }

  /// Tasks belong to a project. `sprint_id` is NULL while a task sits in the
  /// product backlog; deleting a sprint moves its tasks back to the backlog.
  Future<void> _createTasksTable(DatabaseExecutor db, String name) async {
    await db.execute('''
      CREATE TABLE $name (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        sprint_id INTEGER,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL,
        priority TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'task',
        story_points INTEGER,
        assignee TEXT,
        tags TEXT,
        created_at TEXT,
        FOREIGN KEY (project_id) REFERENCES ${AppConstants.tableProjects}(id) ON DELETE CASCADE,
        FOREIGN KEY (sprint_id) REFERENCES ${AppConstants.tableSprints}(id) ON DELETE SET NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ${AppConstants.tableTasks} ADD COLUMN assignee TEXT',
      );
      await db.execute(
        'ALTER TABLE ${AppConstants.tableTasks} ADD COLUMN tags TEXT',
      );
    }
    if (oldVersion < 3) {
      await _migrateToV3(db);
    }
  }

  Future<void> _migrateToV3(Database db) async {
    const projects = AppConstants.tableProjects;
    const sprints = AppConstants.tableSprints;
    const tasks = AppConstants.tableTasks;
    await db.transaction((txn) async {
      await txn.execute(
        "ALTER TABLE $projects ADD COLUMN key TEXT NOT NULL DEFAULT ''",
      );
      await txn.execute(
        "ALTER TABLE $sprints ADD COLUMN goal TEXT NOT NULL DEFAULT ''",
      );
      // Foreign keys were never enforced before v3, so rows of deleted
      // projects / sprints may still exist. Drop them before rebuilding.
      await txn.execute(
        'DELETE FROM $sprints WHERE project_id NOT IN (SELECT id FROM $projects)',
      );
      await _createTasksTable(txn, '${tasks}_v3');
      await txn.execute('''
        INSERT INTO ${tasks}_v3 (id, project_id, sprint_id, title, description,
          status, priority, type, story_points, assignee, tags, created_at)
        SELECT t.id, s.project_id, t.sprint_id, t.title, t.description,
          t.status, t.priority, 'task', NULL, t.assignee, t.tags, NULL
        FROM $tasks t JOIN $sprints s ON s.id = t.sprint_id
      ''');
      await txn.execute('DROP TABLE $tasks');
      await txn.execute('ALTER TABLE ${tasks}_v3 RENAME TO $tasks');
      await normalizeActiveSprints(txn);
    });
  }

  /// Keeps at most one active sprint per project (the latest one); other
  /// "Active" sprints become "Planned". Before v3 every new sprint defaulted
  /// to Active, which conflicts with the one-active-sprint rule.
  static Future<void> normalizeActiveSprints(DatabaseExecutor db) async {
    const sprints = AppConstants.tableSprints;
    await db.execute('''
      UPDATE $sprints SET status = 'Planned'
      WHERE status = 'Active' AND EXISTS (
        SELECT 1 FROM $sprints newer
        WHERE newer.project_id = $sprints.project_id
          AND newer.status = 'Active'
          AND (newer.start_date > $sprints.start_date
            OR (newer.start_date = $sprints.start_date AND newer.id > $sprints.id))
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
