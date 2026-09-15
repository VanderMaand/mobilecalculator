import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'game_assets';
  static const String _prefsKey = 'game_assets_data';

  // ===================== WEB FALLBACK (SharedPreferences) =====================

  Future<List<Map<String, dynamic>>> _getAssetsPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json == null || json.isEmpty) return [];
    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> _saveAssetsPrefs(List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(data));
  }

  // ============================ SQLITE (Mobile) ============================

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      if (kIsWeb) {
        var factory = databaseFactoryFfiWeb;
        return await factory.openDatabase(
          'studio_db.db',
          options: OpenDatabaseOptions(
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
          ),
        );
      } else {
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
    } catch (e, stack) {
      developer.log('Gagal membuka database: $e', name: 'DatabaseHelper', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<int> insertAsset(Map<String, dynamic> data) async {
    try {
      if (kIsWeb) {
        final items = await _getAssetsPrefs();
        int nextId = items.isEmpty ? 1 : (items.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
        final newItem = <String, dynamic>{'id': nextId, ...data};
        items.add(newItem);
        await _saveAssetsPrefs(items);
        return nextId;
      }
      final db = await database;
      return await db.insert(tableName, data);
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
      return await db.query(tableName);
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
        items[index] = <String, dynamic>{'id': id, ...data};
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
}