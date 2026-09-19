import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'game_assets';
  static const String userTableName = 'users';
  static const int _version = 3;
  static const String _prefsKey = 'game_assets_data';
  static const String _usersPrefsKey = 'users_data';

  static String get createTableSql => '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      category TEXT,
      cost INTEGER,
      quantity INTEGER NOT NULL DEFAULT 1,
      purchase_date TEXT
    )
  ''';

  static String get createUsersTableSql => '''
    CREATE TABLE $userTableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      fullname TEXT
    )
  ''';

  // ===================== WEB FALLBACK (SharedPreferences) =====================

  // ----------------------- Users Preferences -----------------------

  Future<List<Map<String, dynamic>>> _getUsersPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_usersPrefsKey);
    if (json == null || json.isEmpty) return [];
    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> _saveUsersPrefs(List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersPrefsKey, jsonEncode(data));
  }

  Future<List<Map<String, dynamic>>> _getAssetsPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json == null || json.isEmpty) return [];
    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded
        .map((e) => _normalizeItem(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _saveAssetsPrefs(List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(data));
  }

  Map<String, dynamic> _normalizeItem(Map<String, dynamic> item) {
    return {
      'id': item['id'],
      'name': item['name'],
      'category': item['category'] ?? item['type'] ?? 'Hardware',
      'cost': item['cost'] ?? 0,
      'quantity': item['quantity'] ?? 1,
      'purchase_date': item['purchase_date'],
    };
  }

  // ============================ SQLITE (Mobile) ============================

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      String path = join(await getDatabasesPath(), 'studio_db.db');
      return await openDatabase(
        path,
        version: _version,
        onCreate: (db, version) async {
          await db.execute('DROP TABLE IF EXISTS $tableName');
          await db.execute(createTableSql);
          await db.execute('DROP TABLE IF EXISTS $userTableName');
          await db.execute(createUsersTableSql);
          await _seedAdmin(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('ALTER TABLE $tableName RENAME TO game_assets_old');
            await db.execute(createTableSql);
            await db.execute('''
              INSERT INTO $tableName (id, name, category, cost, quantity, purchase_date)
              SELECT id, name, COALESCE(type, 'Hardware'), COALESCE(cost, 0), 1, NULL
              FROM game_assets_old
            ''');
            await db.execute('DROP TABLE game_assets_old');
          }
          if (oldVersion < 3) {
            await db.execute('DROP TABLE IF EXISTS $userTableName');
            await db.execute(createUsersTableSql);
            await _seedAdmin(db);
          }
        },
      );
    } catch (e, stack) {
      developer.log('Gagal membuka database: $e', name: 'DatabaseHelper', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> _seedAdmin(DatabaseExecutor db) async {
    final result = await db.query(
      userTableName,
      where: 'username = ?',
      whereArgs: ['admin'],
      limit: 1,
    );
    if (result.isEmpty) {
      await db.insert(userTableName, {
        'username': 'admin',
        'password': 'admin',
        'fullname': 'Administrator',
      });
    }
  }

  Future<int> insertAsset(Map<String, dynamic> data) async {
    try {
      if (kIsWeb) {
        final items = await _getAssetsPrefs();
        int nextId = items.isEmpty ? 1 : (items.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
        final newItem = _normalizeItem(data)..['id'] = nextId;
        items.add(newItem);
        await _saveAssetsPrefs(items);
        return nextId;
      }
      final db = await database;
      return await db.insert(tableName, _normalizeItem(data));
    } catch (e, stack) {
      developer.log('Gagal insert data: $e', name: 'DatabaseHelper', error: e, stackTrace: stack);
      throw Exception('Gagal menyimpan data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAssets() async {
    try {
      if (kIsWeb) {
        return await _getAssetsPrefs();
      }
      final db = await database;
      final rows = await db.query(tableName, orderBy: 'id ASC');
      return rows.map(_normalizeItem).toList();
    } catch (e, stack) {
      developer.log('Gagal mengambil data: $e', name: 'DatabaseHelper', error: e, stackTrace: stack);
      throw Exception('Gagal memuat data: $e');
    }
  }

  Future<int> updateAsset(int id, Map<String, dynamic> data) async {
    try {
      if (kIsWeb) {
        final items = await _getAssetsPrefs();
        final index = items.indexWhere((e) => e['id'] == id);
        if (index == -1) return 0;
        final updatedItem = _normalizeItem(data)..['id'] = id;
        items[index] = updatedItem;
        await _saveAssetsPrefs(items);
        return 1;
      }
      final db = await database;
      return await db.update(tableName, data, where: 'id = ?', whereArgs: [id]);
    } catch (e, stack) {
      developer.log('Gagal update data: $e', name: 'DatabaseHelper', error: e, stackTrace: stack);
      throw Exception('Gagal memperbarui data: $e');
    }
  }

  Future<int> deleteAsset(int id) async {
    try {
      if (kIsWeb) {
        final items = await _getAssetsPrefs();
        final index = items.indexWhere((e) => e['id'] == id);
        if (index == -1) return 0;
        items.removeAt(index);
        await _saveAssetsPrefs(items);
        return 1;
      }
      final db = await database;
      return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e, stack) {
      developer.log('Gagal hapus data: $e', name: 'DatabaseHelper', error: e, stackTrace: stack);
      throw Exception('Gagal menghapus data: $e');
    }
  }

  // ============================ AUTH (Users) ============================

  Future<bool> isUsernameTaken(String username) async {
    final user = await _findUserByUsername(username);
    return user != null;
  }

  Future<Map<String, dynamic>?> _findUserByUsername(String username) async {
    if (kIsWeb) {
      final users = await _getUsersPrefs();
      final index = users.indexWhere(
        (e) => (e['username'] ?? '').toString().toLowerCase() == username.toLowerCase(),
      );
      if (index == -1) return null;
      return users[index];
    }
    final db = await database;
    final rows = await db.query(
      userTableName,
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<String?> registerUser({
    required String username,
    required String password,
    String? fullname,
  }) async {
    final normalized = username.trim();
    if (await isUsernameTaken(normalized)) {
      return 'Username sudah terdaftar';
    }
    try {
      if (kIsWeb) {
        final users = await _getUsersPrefs();
        int nextId = users.isEmpty ? 1 : (users.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
        users.add({
          'id': nextId,
          'username': normalized,
          'password': password,
          'fullname': fullname?.trim() ?? normalized,
        });
        await _saveUsersPrefs(users);
        return null;
      }
      final db = await database;
      await db.insert(userTableName, {
        'username': normalized,
        'password': password,
        'fullname': fullname?.trim() ?? normalized,
      });
      return null;
    } catch (e, stack) {
      developer.log('Gagal registrasi: $e', name: 'DatabaseHelper', error: e, stackTrace: stack);
      return 'Gagal menyimpan data: $e';
    }
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final user = await _findUserByUsername(username.trim());
    if (user != null && user['password'] == password) {
      return {
        'id': user['id'],
        'username': user['username'],
        'fullname': user['fullname'] ?? user['username'],
      };
    }
    return null;
  }
}