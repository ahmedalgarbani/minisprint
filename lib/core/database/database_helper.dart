import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableProjects} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableSprints} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES ${AppConstants.tableProjects}(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableTasks} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sprint_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL,
        priority TEXT NOT NULL,
        assignee TEXT,
        tags TEXT,
        FOREIGN KEY (sprint_id) REFERENCES ${AppConstants.tableSprints}(id) ON DELETE CASCADE
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
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
