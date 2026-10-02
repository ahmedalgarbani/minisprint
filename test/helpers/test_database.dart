import 'dart:io';

import 'package:minisprint/core/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A real SQLite database in a temp file, via sqflite_common_ffi.
class TestDatabase {
  final Directory dir;
  final String path;

  TestDatabase._(this.dir, this.path);

  static Future<TestDatabase> create() async {
    sqfliteFfiInit();
    final dir = await Directory.systemTemp.createTemp('minisprint_test');
    return TestDatabase._(dir, '${dir.path}/test.db');
  }

  DatabaseFactory get factory => databaseFactoryFfi;

  DatabaseHelper helper() => DatabaseHelper(factory: factory, path: path);

  Future<void> dispose() => dir.delete(recursive: true);
}
