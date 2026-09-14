import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'game_assets';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'studio_db.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            type TEXT,
            cost INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertAsset(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableName, data);
  }

  Future<List<Map<String, dynamic>>> getAssets() async {
    final db = await database;
    return await db.query(tableName);
  }

  Future<int> updateAsset(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(tableName, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAsset(int id) async {
    final db = await database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}