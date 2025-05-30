import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    return _database ??= await initDatabase();
  }

  Future<Database> initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'rfid.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tags (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tag TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertTag(String tag) async {
    final db = await database;
    await db.insert('tags', {'tag': tag});
  }

  Future<List<Map<String, dynamic>>> getTags() async {
    final db = await database;
    return await db.query('tags');
  }
}
