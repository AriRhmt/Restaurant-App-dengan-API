import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const _dbName = 'app.db';
  static const _table = 'favorites';
  static const _prefsKey = 'web_favorites_rows';
  static Database? _db;

  Future<Database> _open() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web');
    }
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            city TEXT NOT NULL,
            rating REAL NOT NULL,
            description TEXT NOT NULL,
            image TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> toggleFavorite(Map<String, dynamic> restaurant) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = (prefs.getStringList(_prefsKey) ?? <String>[]).toList();
      final id = restaurant['id'] as String;
      final idx = list.indexWhere((s) => s.startsWith('$id|'));
      if (idx >= 0) {
        list.removeAt(idx);
      } else {
        final serialized = [
          restaurant['id'],
          restaurant['name'],
          restaurant['city'],
          (restaurant['rating'] as num).toString(),
          restaurant['description'],
          restaurant['image'],
        ].join('|');
        list.add(serialized);
      }
      await prefs.setStringList(_prefsKey, list);
    } else {
      final db = await _open();
      final id = restaurant['id'] as String;
      final existing = await db.query(_table, where: 'id = ?', whereArgs: [id]);
      if (existing.isNotEmpty) {
        await db.delete(_table, where: 'id = ?', whereArgs: [id]);
      } else {
        await db.insert(_table, restaurant,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  Future<bool> isFavorite(String id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefsKey) ?? <String>[];
      return list.any((s) => s.startsWith('$id|'));
    } else {
      final db = await _open();
      final rows = await db.query(_table, where: 'id = ?', whereArgs: [id]);
      return rows.isNotEmpty;
    }
  }

  Future<List<Map<String, dynamic>>> allFavorites() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefsKey) ?? <String>[];
      final rows = list.map((s) {
        final parts = s.split('|');
        return <String, dynamic>{
          'id': parts[0],
          'name': parts[1],
          'city': parts[2],
          'rating': double.tryParse(parts[3]) ?? 0.0,
          'description': parts[4],
          'image': parts[5],
        };
      }).toList()
        ..sort((a, b) => (a['name'] as String).toLowerCase().compareTo((b['name'] as String).toLowerCase()));
      return rows;
    } else {
      final db = await _open();
      return db.query(_table, orderBy: 'name ASC');
    }
  }
}
